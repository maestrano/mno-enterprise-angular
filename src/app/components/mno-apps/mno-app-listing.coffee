angular.module 'mnoEnterpriseAngular'
  .component('mnoAppListing', {
    templateUrl: 'app/components/mno-apps/mno-app-listing.html',
    bindings: {
      isPublic: '@'
    }
    controller: ($scope, toastr, MnoeOrganizations, MnoeMarketplace, MnoeConfig) ->
      vm = this

      #====================================
      # Initialization
      #====================================
      vm.$onInit = ->
        vm.isPublic = vm.isPublic == "true"
        vm.isLoading = true
        vm.selectedCategory = ''
        vm.searchTerm = ''
        vm.isMarketplaceCompare = MnoeConfig.isMarketplaceComparisonEnabled()
        vm.showCompare = false
        vm.nbAppsToCompare = 0
        vm.appState = if vm.isPublic then "public.product" else "home.marketplace.app"
        vm.initialize()
      #====================================
      # Scope Management
      #====================================

      vm.appsFilter = (app) ->
        if (vm.searchTerm? && vm.searchTerm.length > 0) || !vm.selectedCategory
          return true
        else
          return _.contains(app.categories, vm.selectedCategory)

      # Cancel comparison
      vm.cancelComparison = ->
        vm.showCompare = false

      # Uncheck all checkboxes
      vm.uncheckAllApps = () ->
        angular.forEach(vm.apps, (items) ->
          items.toCompare = false
        )

      # Toggle compare block
      vm.enableComparison = ->
        vm.nbAppsToCompare = 0
        vm.uncheckAllApps()
        vm.showCompare = true

      vm.toggleAppToCompare = (app) ->
        selected = app.toCompare
        if selected && vm.nbAppsToCompare >= 4
          toastr.info("mno_enterprise.templates.dashboard.marketplace.index.toastr.error")
          app.toCompare = false
        else
          vm.nbAppsToCompare += if selected then 1 else (-1)

      vm.canBeCompared = ->
        return vm.nbAppsToCompare <= 4 && vm.nbAppsToCompare >=2

      vm.initialize = ->
        vm.isLoading = true
        MnoeMarketplace.getApps().then(
          (response) ->
            # Remove restangular decoration
            response = response.plain()

            vm.categories = response.categories
            vm.apps = response.apps
      ).finally(-> vm.isLoading = false)

      $scope.$watch MnoeOrganizations.getSelectedId, (val) ->
        if val?
          vm.initialize()

      return
    })
