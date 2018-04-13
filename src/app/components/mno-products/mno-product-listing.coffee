angular.module 'mnoEnterpriseAngular'
  .component('mnoProductListing', {
    templateUrl: 'app/components/mno-products/mno-product-listing.html',
    bindings: {
      isPublic: '@',
      isLocal: '<'
    }
    controller: ($scope, toastr, MnoeOrganizations, MnoeMarketplace, MnoeConfig) ->
      vm = this

      #====================================
      # Initialization
      #====================================
      vm.$onInit = ->
        vm.publicPage = vm.isPublic == "true"
        vm.isLoading = true
        vm.selectedCategory = ''
        vm.searchTerm = ''
        vm.isMarketplaceCompare = MnoeConfig.isMarketplaceComparisonEnabled()
        vm.showCompare = false
        vm.nbProductsToCompare = 0
        vm.productState = if vm.publicPage then "public.product" else "home.marketplace.product"
        vm.appOrProduct = (product) ->
          if product.app_id
            "({appId: '#{product.app_id}', productNid: '#{product.nid}'})"
          else
            "({productId: '#{product.id}', productNid: '#{product.nid}'})"
        vm.productRef = (product) ->
          vm.productState + vm.appOrProduct(product)

        vm.initialize()
      #====================================
      # Scope Management
      #====================================

      vm.productsFilter = (product) ->
        if (vm.searchTerm? && vm.searchTerm.length > 0) || !vm.selectedCategory
          return true
        else
          return _.contains(product.categories, vm.selectedCategory)

      # Cancel comparison
      vm.cancelComparison = ->
        vm.showCompare = false

      # Uncheck all checkboxes
      uncheckAllProducts = () ->
        angular.forEach(vm.products, (product) ->
          product.toCompare = false
        )

      # Toggle compare block
      vm.enableComparison = ->
        vm.nbProductsToCompare = 0
        uncheckAllProducts()
        vm.showCompare = true

      vm.toggleProductToCompare = (product) ->
        selected = product.toCompare
        if selected && vm.nbProductsToCompare >= 4
          toastr.info("mno_enterprise.templates.dashboard.marketplace.index.toastr.error")
          product.toCompare = false
        else
          vm.nbProductsToCompare += if selected then 1 else (-1)

      vm.canBeCompared = ->
        return vm.nbProductsToCompare <= 4 && vm.nbProductsToCompare >=2

      vm.initialize = ->
        vm.isLoading = true
        MnoeMarketplace.getMarketplace().then(
          (response) ->
            # Remove restangular decoration
            vm.products = if vm.isLocal
              _.filter(response.products, (product) -> product.local)
            else
              _.filter(response.products, (product) -> !product.local)

            if vm.publicPage
              vm.products = _.filter(vm.products, (product) -> _.includes(MnoeConfig.publicProducts(), product.nid))
      ).finally(-> vm.isLoading = false)

      $scope.$watch MnoeOrganizations.getSelectedId, (val) ->
        if val?
          vm.initialize()

      return
    })
