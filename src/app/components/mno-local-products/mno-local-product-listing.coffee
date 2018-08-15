#
# Mnoe Products
#

angular.module 'mnoEnterpriseAngular'
  .component('mnoLocalProductListing', {
    templateUrl: 'app/components/mno-local-products/mno-local-product-listing.html',
    bindings: {
      isPublic: '@'
    }
    controller: ($scope, MnoeOrganizations, MnoeMarketplace, MnoeConfig) ->
      vm = this

      #====================================
      # Initialization
      #====================================
      vm.$onInit = ->
        vm.publicPage = vm.isPublic == "true"
        vm.productState = if vm.publicPage then "public.local_product" else "home.marketplace.local_product"
        vm.isLoading = true

      vm.initialize = ->
        vm.isLoading = true
        MnoeMarketplace.getApps().then(
          (response) ->
            if vm.publicPage
              vm.products = _.filter(response.products, (product) -> product.local && _.includes(MnoeConfig.publicLocalProducts(), product.nid))
            else
              vm.products = _.filter(response.products, 'local')
          ).finally(-> vm.isLoading = false)

      #====================================
      # Post-Initialization
      #====================================
      $scope.$watch MnoeOrganizations.getSelectedId, (val) ->
        vm.initialize()

      return
    })
