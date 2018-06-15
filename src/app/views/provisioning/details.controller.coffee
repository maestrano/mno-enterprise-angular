angular.module 'mnoEnterpriseAngular'
  .controller('ProvisioningDetailsCtrl', ($scope, $q, $stateParams, $state, $filter, MnoeMarketplace, MnoeProvisioning, MnoeOrganizations, schemaForm, ProvisioningHelper, toastr) ->
    vm = this

    vm.form = [ "*" ]
    vm.subscription = MnoeProvisioning.getCachedSubscription()

    # We must use model schemaForm's sf-model, as #json_schema_opts are namespaced under model
    vm.model = vm.subscription.custom_data || {}

    # Methods under the vm.model are used for calculated fields under #json_schema_opts, which are set on third-party adapters.
    # Used to calculate the end date for forms with a contractEndDate.
    vm.model.calculateEndDate = (startDate, contractLength) ->
      return null unless startDate && contractLength
      moment(startDate)
      .add(contractLength.split('Months')[0], 'M')
      .format('YYYY-MM-DD')

    # Used for forms that automatically calculate the startDate.
    vm.model.timeNow = () ->
      $filter('date')(new Date(), 'yyyy-MM-dd')

    # Workaround. You can only specify defaults in the schema, and not the vm.form section.
    # Since we are getting the schemas remotely, we must find a way to set defaults using vm.form.
    vm.model.defaultContractLength = () ->
      'monthly'

    urlParams =
      productId: $stateParams.productId,
      subscriptionId: $stateParams.subscriptionId,
      editAction: $stateParams.editAction,
      cart: $stateParams.cart

    skipPricing = () ->
      # Able to skip pricing if subscription already has a product pricing, or pricing plans are skipped automatically.
      vm.subscription.product_pricing || ProvisioningHelper.skipPriceSelection(vm.subscription.product)

    handleRedirect = (product) ->
      # If there is no custom schema and pricings are skipped -- go directly to the confirm page.
      if skipPricing()
        $state.go('home.provisioning.confirm', urlParams, {reload: true})
      # Default: If we can't skip pricings, we must go back to the order page to choose a price. Happens when we reload page on a new order.
      else
        $state.go('home.provisioning.order', urlParams, {reload: true})

    # The schema is contained in field vm.product.custom_schema
    # jsonref is used to resolve $ref references
    # jsonref is not cyclic at this stage hence the need to make a
    # reasonable number of passes (2 below + 1 in the sf-schema directive)
    # to resolve cyclic references
    setCustomSchema = (product) ->
      # If there is a custom schema and we can skip pricing, stay on this page.
      return handleRedirect(product) unless product.custom_schema && skipPricing()
      vm.model = vm.subscription.custom_data || {}
      parsedSchema = JSON.parse(product.custom_schema)
      schema = parsedSchema.json_schema || parsedSchema
      vm.form = parsedSchema.asf_options || ["*"]
      schemaForm.jsonref(schema)
        .then((schema) -> schemaForm.jsonref(schema))
        .then((schema) -> schemaForm.jsonref(schema))
        .then((schema) ->
          vm.schema = schema
          )

    fetchSubscription = () ->
      orgPromise = MnoeOrganizations.get()
      initPromise = MnoeProvisioning.initSubscription({productId: urlParams.productId, subscriptionId: urlParams.subscriptionId, cart: urlParams.cart})

      $q.all({organization: orgPromise, subscription: initPromise}).then(
        (response) ->
          vm.orgCurrency = response.organization.organization?.billing_currency || MnoeConfig.marketplaceCurrency()
          vm.subscription = response.subscription
        )

    filterCurrencies = (productPricings) ->
      _.filter(vm.subscription.product.pricing_plans,
        (pp) -> !ProvisioningHelper.pricedPlan(pp) || _.some(pp.prices, (p) -> p.currency == vm.orgCurrency)
      )

    fetchProduct = () ->
      # When in edit mode, we will be getting the product ID from the subscription, otherwise from the url.
      vm.productId = vm.subscription.product?.id || urlParams.productId
      MnoeMarketplace.getProduct(vm.productId).then(
        (response) ->
          vm.subscription.product = response

          # Filters the pricing plans not containing current currency
          vm.subscription.product.pricing_plans = filterCurrencies(vm.subscription.product.product_pricings)
          MnoeProvisioning.setSubscription(vm.subscription)
        )

    fetchCustomSchema = () ->
      MnoeMarketplace.fetchCustomSchema(vm.productId, { editAction: urlParams.editAction }).then((response) ->
        # Some products have custom schemas, whereas others do not.
        vm.subscription.product.custom_schema = response
        )

    if _.isEmpty(vm.subscription)
      vm.isLoading = true
      fetchSubscription().then(fetchProduct).then(fetchCustomSchema)
        .then(() -> setCustomSchema(vm.subscription.product))
        .catch((error) ->
          toastr.error('mno_enterprise.dashboard.provisioning.subscriptions.product_error')
          $state.go('home.subscriptions', {subType: if urlParams.cart then 'cart' else 'active'})
        )
        .finally(() -> vm.isLoading = false)
    else
      setCustomSchema(vm.subscription.product)

    vm.editPlanText = "mno_enterprise.templates.dashboard.provisioning.details." + urlParams.editAction.toLowerCase() + "_title"

    vm.submit = (form) ->
      $scope.$broadcast('schemaFormValidate')
      return unless form.$valid
      vm.subscription.custom_data = vm.model
      MnoeProvisioning.setSubscription(vm.subscription)
      $state.go('home.provisioning.confirm', urlParams)

    # Delete the cached subscription when we are leaving the subscription workflow.
    $scope.$on('$stateChangeStart', (event, toState) ->
      switch toState.name
        when "home.provisioning.order", "home.provisioning.order_summary", "home.provisioning.confirm"
          null
        else
          MnoeProvisioning.setSubscription({})
    )

    return
  )
