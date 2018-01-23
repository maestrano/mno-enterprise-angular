#
# Mnoe Products
#

angular.module 'mnoEnterpriseAngular'
  .component('mnoLocalProductListing', {
    templateUrl: 'app/components/mno-local-products/mno-local-product-listing.html',
    bindings: {
      isPublic: '@'
    }
    controller: (MnoeMarketplace, MnoeConfig) ->
      vm = this

      #====================================
      # Initialization
      #====================================
      vm.$onInit = ->
        vm.isPublic = vm.isPublic == "true"
        vm.productState = if vm.isPublic then "public.local_product" else "home.marketplace.local_product"
        vm.isLoading = true
        MnoeMarketplace.getApps().then(
          (response) ->
            if vm.isPublic
              vm.products = _.filter(response.products, (product) -> product.local)
            else
              vm.products = _.filter(response.products, (product) -> product.local && _.includes(MnoeConfig.publicLocalProducts(), product.nid))
            vm.isLoading = false
          )

      return
    })
