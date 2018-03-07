angular.module 'mnoEnterpriseAngular'
  .controller('ProvisioningOrderCtrl', ($q, $state, $stateParams, MnoeOrganizations, MnoeMarketplace, MnoeProvisioning, MnoeConfig, PRICING_TYPES) ->

    vm = this
    vm.isLoading = true
    vm.product = null

    orgPromise = MnoeOrganizations.get()
    prodsPromise = MnoeMarketplace.getProducts()
    initPromise = MnoeProvisioning.initSubscription({productNid: $stateParams.nid, subscriptionId: $stateParams.id})

    $q.all({organization: orgPromise, products: prodsPromise, subscription: initPromise}).then(
      (response) ->
        vm.orgCurrency = response.organization.organization?.billing_currency || MnoeConfig.marketplaceCurrency()
        vm.subscription = response.subscription

        MnoeMarketplace.findProduct({id: vm.subscription.product?.id, nid: $stateParams.nid}).then(
          (response) ->
            vm.subscription.product = response

            # Filters the pricing plans not containing current currency
            vm.subscription.product.pricing_plans = _.filter(vm.subscription.product.pricing_plans,
              (pp) -> (pp.pricing_type in PRICING_TYPES['unpriced']) || _.some(pp.prices, (p) -> p.currency == vm.orgCurrency)
            )

            vm.select_plan = (pricingPlan)->
              vm.subscription.product_pricing = pricingPlan
              vm.subscription.max_licenses ||= 1 if vm.subscription.product_pricing.license_based

            MnoeProvisioning.setSubscription(vm.subscription)
        )
    ).finally(-> vm.isLoading = false)

    vm.next = (subscription) ->
      MnoeProvisioning.setSubscription(subscription)
      if vm.subscription.product.custom_schema?
        $state.go('home.provisioning.additional_details')
      else
        $state.go('home.provisioning.confirm')

    # Return true if the plan has a dollar value
    vm.pricedPlan = (plan) ->
      plan.pricing_type not in PRICING_TYPES['unpriced']

    return
  )
