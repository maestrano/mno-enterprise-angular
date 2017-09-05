#
# Mnoe Products
#

angular.module 'mnoEnterpriseAngular'
  .component('mnoMarketplaceProducts', {
    templateUrl: 'app/components/mno-marketplace-products/mno-marketplace-products.html',
    controller: (MnoeMarketplace) ->
      vm = this

      #====================================
      # Initialization
      #====================================
      vm.isLoading = true
      MnoeMarketplace.getLocalProducts().then(
        (response) ->
          vm.products = response
          vm.isLoading = false
      )

      return
    })
