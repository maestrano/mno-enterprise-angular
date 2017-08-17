#============================================
#     Marketplace product
#============================================
angular.module 'mnoEnterpriseAngular'
  .controller('MarketplaceProductCtrl',($stateParams, $state, MnoeMarketplace, MnoeProductInstances) ->

    vm = this

    vm.isLoading = true
    vm.product = {}
    vm.isButtonShown = false

    vm.showButton = () ->
      vm.isButtonShown = true

    vm.hideButton = () ->
      vm.isButtonShown = false

    vm.getProduct = () ->
      MnoeProductInstances.addProductInstance(vm.product.id).then(
        (response) ->
      ).finally(-> $state.go('home.impac'))

    MnoeMarketplace.getProduct($stateParams.productId).then(
      (response) ->
        vm.product = response.plain()

    ).finally(-> vm.isLoading = false)

    return
  )
