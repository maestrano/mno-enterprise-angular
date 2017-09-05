#
# Mnoe Products
#

angular.module 'mnoEnterpriseAngular'
  .component('mnoMarketplaceProducts', {
    templateUrl: 'app/components/mno-marketplace-products/mno-marketplace-products.html',
    bindings: {
      view: '@'
    }

    controller: (MnoeMarketplace) ->

      vm = this
      vm.isLoading = true

      #====================================
      # Initialization
      #====================================
      MnoeMarketplace.getLocalProducts().then(
        (response) ->
          vm.products = response
          vm.isLoading = false
      )

      return
    })
