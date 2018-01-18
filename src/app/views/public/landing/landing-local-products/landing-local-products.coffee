#
# Mnoe Products
#

angular.module 'mnoEnterpriseAngular'
  .component('landingLocalProducts', {
    templateUrl: 'app/views/public/landing/landing-local-products/landing-local-products.html',
    bindings: {
      canProvision: '@'
    }
    controller: (MnoeMarketplace, MnoeConfig) ->
      vm = this

      #====================================
      # Initialization
      #====================================
      vm.isLoading = true
      MnoeMarketplace.getApps().then(
        (response) ->
          vm.products = _.filter(response.products, (product) -> product.local && _.includes(MnoeConfig.publicLocalProducts(), product.nid))
          vm.isLoading = false
      )
      return
    })
