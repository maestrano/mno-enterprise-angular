#============================================
#     Marketplace product
#============================================
angular.module 'mnoEnterpriseAngular'
  .controller('MarketplaceProductCtrl',($stateParams, MnoeMarketplace) ->

    vm = this

    vm.isLoading = true
    vm.product = {}

    MnoeMarketplace.getProduct($stateParams.productId).then(
      (response) ->
        vm.product = response.plain()

    ).finally(-> vm.isLoading = false)

    return
  )
