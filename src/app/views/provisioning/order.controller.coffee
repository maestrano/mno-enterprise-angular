angular.module 'mnoEnterpriseAngular'
  .controller('ProvisioningOrderCtrl', ($q, $state, $stateParams, MnoeOrganizations, MnoeMarketplace, MnoeConfig) ->

    vm = this
    vm.isLoading = true
    vm.product = null

    orgPromise = MnoeOrganizations.get()
    prodsPromise = MnoeMarketplace.getProducts()
    initPromise = MnoeProvisioning.initSubscription({productNid: $stateParams.nid, subscriptionId: $stateParams.id})

    $q.all({organization: orgPromise, products: prodsPromise, subscription: initPromise}).then(
      (response) ->
        vm.orgCurrency = response.organization.billing?.current?.options?.iso_code || MnoeConfig.marketplaceCurrency()
        vm.subscription = response.subscription

        MnoeMarketplace.findProduct({id: vm.subscription.product?.id, nid: $stateParams.nid}).then(
          (response) ->
            vm.subscription.product = response

            # Filters the pricing plans not containing current currency
            vm.subscription.product.product_pricings = _.filter(vm.subscription.product.product_pricings,
              (pp) -> _.some(pp.prices, (p) -> p.currency == vm.orgCurrency)
            )

            MnoeProvisioning.setSubscription(vm.subscription)
        )
    ).finally(-> vm.isLoading = false)

    vm.next = (subscription) ->
      MnoeProvisioning.setSubscription(subscription)
      if vm.subscription.product.custom_schema?
        $state.go('home.provisioning.additional_details')
      else
        $state.go('home.provisioning.confirm')

    return
  )
