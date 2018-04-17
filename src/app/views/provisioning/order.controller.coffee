angular.module 'mnoEnterpriseAngular'
  .controller('ProvisioningOrderCtrl', ($scope, $q, $state, $stateParams, MnoeOrganizations, MnoeMarketplace, MnoeProvisioning, MnoeConfig, ProvisioningHelper) ->

    vm = this
    vm.isLoading = true
    vm.product = null

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

            # Skip pricing selection when applicable
            vm.next(vm.subscription) if vm.skipPriceSelection(vm.subscription.product)

            # Filters the pricing plans not containing current currency
            vm.subscription.product.pricing_plans = _.filter(vm.subscription.product.pricing_plans,
              (pp) -> !vm.pricedPlan(pp) || _.some(pp.prices, (p) -> p.currency == vm.orgCurrency)
            )

            vm.selectPlan = (pricingPlan)->
              vm.subscription.product_pricing = pricingPlan
              vm.subscription.max_licenses ||= 1 if vm.subscription.product_pricing.license_based


            MnoeProvisioning.setSubscription(vm.subscription)
        )
    ).finally(-> vm.isLoading = false)

    vm.next = (subscription) ->
      MnoeProvisioning.setSubscription(subscription)
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

    # Skip pricing selection for products with product_type 'application' if
    # single billing is disabled or if single billing is enabled but externally managed
    vm.skipPriceSelection = (product) ->
      product.product_type == 'application' && (!product.single_billing_enabled || !product.billed_locally)

    return
  )
