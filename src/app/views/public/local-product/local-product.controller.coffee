angular.module 'mnoEnterpriseAngular'
  .controller('LandingLocalProductCtrl',($scope, $q, $stateParams, $state, MnoeMarketplace, MnoeOrganizations, MnoeConfig) ->

    vm = this

    vm.isPriceShown = MnoeConfig.isMarketplacePricingEnabled()
    vm.isLoading = true

    # Retrieve the products
    MnoeMarketplace.getApps().then(
      (response) ->
        products = _.filter(response.products, (product) -> product.local)
        products = response.products
        organization = response.organization

        # App to be displayed
        productId = $stateParams.productId
        vm.product = _.findWhere(products, { nid: productId })
        vm.product ||= _.findWhere(products, { id:  productId })
    ).finally(-> vm.isLoading = false)

    return
  )
