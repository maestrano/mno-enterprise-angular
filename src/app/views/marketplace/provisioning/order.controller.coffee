angular.module 'mnoEnterpriseAngular'
  .controller('ProvisioningOrderCtrl', ($q, $state, $stateParams, MnoeOrganizations, MnoeProvisioning) ->

    vm = this
    vm.isLoading = true

    orgPromise = MnoeOrganizations.get()
    prodsPromise = MnoeProvisioning.getProducts()

    $q.all({organization: orgPromise, products: prodsPromise}).then(
      (response) ->
        vm.orgCurrency = response.organization.billing?.current?.options?.iso_code || 'USD'
        vm.product = MnoeProvisioning.findProduct($stateParams.nid)

        MnoeProvisioning.setCurrentProduct(vm.product)

        # Filters the pricing plans not containing current currency
        vm.product.product_pricings = _.filter(vm.product.product_pricings,
          (pp) -> _.some(pp.prices, (p) -> p.currency == vm.orgCurrency)
        )
    ).finally(-> vm.isLoading = false)

    vm.next = (pricingPlan) ->
      MnoeProvisioning.setPricingPlan(pricingPlan)
      if vm.product.custom_schema?
        $state.go('home.provisioning.additional_details')
      else
        $state.go('home.provisioning.confirm')

    return
  )
