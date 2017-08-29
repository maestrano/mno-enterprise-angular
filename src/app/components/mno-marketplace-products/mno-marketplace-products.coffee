#
# Mnoe Products
#

angular.module 'mnoEnterpriseAngular'
  .component('mnoMarketplaceProducts', {
    templateUrl: 'app/components/mno-marketplace-products/mno-marketplace-products.html',
    bindings: {
      view: '@'
    }

    controller: (MnoeProvisioning) ->

      vm = this
      vm.isLoading = true

      #====================================
      # Initialization
      #====================================
      MnoeProvisioning.getProducts().then(
        (response) ->
          response = response.plain()
          vm.products = response.products

          vm.isLoading = false
      )

      return
    })
