angular.module 'mnoEnterpriseAngular'
  .controller('ProvisioningDetailsCtrl', ($scope, $q, $stateParams, $state, MnoeMarketplace, MnoeProvisioning, MnoeOrganizations, schemaForm, ProvisioningHelper, toastr) ->
    vm = this

    vm.form = [ "*" ]
    vm.subscription = MnoeProvisioning.getCachedSubscription()

    # We must use model schemaForm's sf-model, as #json_schema_opts are namespaced under model
    vm.model = vm.subscription.custom_data || {}

    # Methods under the vm.model are used for calculated fields under #json_schema_opts.
    # Used to calculate the end date for forms with a contractEndDate.
    vm.model.calculateEndDate = (startDate, contractLength) ->
      return null unless startDate && contractLength
      moment(startDate)
      .add(contractLength.split('Months')[0], 'M')
      .format('YYYY-MM-DD')

    urlParams =
      productId: $stateParams.productId,
      subscriptionId: $stateParams.subscriptionId,
      editAction: $stateParams.editAction

    # The schema is contained in field vm.product.custom_schema
    # jsonref is used to resolve $ref references
    # jsonref is not cyclic at this stage hence the need to make a
    # reasonable number of passes (2 below + 1 in the sf-schema directive)
    # to resolve cyclic references
    setCustomSchema = (product) ->
      vm.model = vm.subscription.custom_data || {}
      return $state.go('home.provisioning.confirm', urlParams, {reload: true}) unless product.custom_schema
      schemaForm.jsonref(JSON.parse(product.custom_schema))
        .then((schema) -> schemaForm.jsonref(schema))
        .then((schema) -> schemaForm.jsonref(schema))
        .then((schema) ->
          vm.schema = if schema.json_schema then schema.json_schema else schema
          vm.form = if schema.asf_options then schema.asf_options else ["*"]
          )

    fetchSubscription = () ->
      orgPromise = MnoeOrganizations.get()
      initPromise = MnoeProvisioning.initSubscription({productId: urlParams.productId, subscriptionId: urlParams.subscriptionId})

      $q.all({organization: orgPromise, subscription: initPromise}).then(
        (response) ->
          vm.orgCurrency = response.organization.organization?.billing_currency || MnoeConfig.marketplaceCurrency()
          vm.subscription = response.subscription
          vm.isEditMode = !_.isEmpty(vm.subscription.custom_data)
        )

    filterCurrencies = (productPricings) ->
      _.filter(vm.subscription.product.pricing_plans,
        (pp) -> !ProvisioningHelper.pricedPlan(pp) || _.some(pp.prices, (p) -> p.currency == vm.orgCurrency)
      )

    fetchProduct = () ->
      # When in edit mode, we will be getting the product ID from the subscription, otherwise from the url.
      vm.productId = vm.subscription.product?.id || urlParams.productId
      MnoeMarketplace.getProduct(vm.productId, { editAction: urlParams.editAction }).then(
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
      # We cannot go directly to this page if creating a new subscription, we must first choose a product pricing.
      # eg. when refreshing on the details page when creating a new subscription.
      return $state.go('home.provisioning.order', urlParams, {reload: true}) if urlParams.editAction == 'new'
      vm.isLoading = true
      fetchSubscription().then(fetchProduct).then(fetchCustomSchema)
        .then(() -> setCustomSchema(vm.subscription.product))
        .catch((error) ->
          toastr.error('mnoe_admin_panel.dashboard.provisioning.subscriptions.product_error')
          $state.go('home.subscriptions')
        )
        .finally(() -> vm.isLoading = false)
    # Ensure that the cached subscription has a custom schema, otherwise redirect to order page.
    else if vm.subscription?.product?.custom_schema
      vm.isEditMode = !_.isEmpty(vm.subscription.custom_data)
      setCustomSchema(vm.subscription.product)
    else
      $state.go('home.provisioning.order', urlParams, {reload: true})

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
