angular.module 'mnoEnterpriseAngular'
  .controller('ProvisioningOrderCtrl', ($scope, $q, $state, $stateParams, MnoeOrganizations, MnoeMarketplace, MnoeProvisioning, MnoeConfig, ProvisioningHelper, PRICING_TYPES) ->

    vm = this
    vm.isLoading = true
    vm.product = null
    vm.selectedCurrency = ''
    vm.currencies = []
    vm.filteredPricingPlans = []
    vm.isCurrencySelectionEnabled = MnoeConfig.isCurrencySelectionEnabled()


    orgPromise = MnoeOrganizations.get()
    prodsPromise = MnoeMarketplace.getProducts()
    initPromise = MnoeProvisioning.initSubscription({productNid: $stateParams.nid, subscriptionId: $stateParams.id})

    # Return true if the plan has a dollar value
    vm.pricedPlan = ProvisioningHelper.pricedPlan

    $q.all({organization: orgPromise, products: prodsPromise, subscription: initPromise}).then(
      (response) ->
        vm.orgCurrency = response.organization.organization?.billing_currency || MnoeConfig.marketplaceCurrency()
        vm.subscription = response.subscription

        MnoeMarketplace.findProduct({id: vm.subscription.product?.id, nid: $stateParams.nid}).then(
          (response) ->
            vm.subscription.product = response

            # Get all the possible currencies
            currenciesArray = []
            _.forEach(vm.subscription.product.pricing_plans,
              (pp) -> _.forEach(pp.prices, (p) -> currenciesArray.push(p.currency)))
            vm.currencies = _.uniq(currenciesArray)
            # Set a default currency
            if vm.currencies.includes(vm.orgCurrency)
              vm.selectedCurrency = vm.orgCurrency
            else
              vm.selectedCurrency = vm.currencies[0]
            vm.pricingPlanFilter()

            vm.select_plan = (pricingPlan)->
              vm.subscription.product_pricing = pricingPlan
              vm.subscription.max_licenses ||= 1 if vm.subscription.product_pricing.license_based

            MnoeProvisioning.setSubscription(vm.subscription)
        )
    ).finally(-> vm.isLoading = false)

    # Filters the pricing plans not containing current currency
    vm.pricingPlanFilter = () ->
      vm.filteredPricingPlans = _.filter(vm.subscription.product.pricing_plans,
        (pp) -> (pp.pricing_type in PRICING_TYPES['unpriced']) || _.some(pp.prices, (p) -> p.currency == vm.selectedCurrency)
      )

    vm.next = (subscription, currency) ->
      MnoeProvisioning.setSubscription(subscription)
      MnoeProvisioning.setSelectedCurrency(currency)
      if vm.subscription.product.custom_schema?
        $state.go('home.provisioning.additional_details', {id: $stateParams.id, nid: $stateParams.nid})
      else
        $state.go('home.provisioning.confirm', {id: $stateParams.id, nid: $stateParams.nid})

    # Delete the cached subscription when we are leaving the subscription workflow.
    $scope.$on('$stateChangeStart', (event, toState) ->
      switch toState.name
        when "home.provisioning.confirm", "home.provisioning.order_summary", "home.provisioning.additional_details"
          null
        else
          MnoeProvisioning.setSubscription({})
    )

    return
  )
