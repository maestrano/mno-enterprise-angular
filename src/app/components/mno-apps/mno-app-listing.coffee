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
        vm.publicPage = vm.isPublic == "true"
        vm.isLoading = true
        vm.selectedCategory = ''
        vm.searchTerm = ''
        vm.isMarketplaceCompare = MnoeConfig.isMarketplaceComparisonEnabled()
        vm.showCompare = false
        vm.nbAppsToCompare = 0
        vm.appState = if vm.publicPage then "public.product" else "home.marketplace.app"
        vm.displayAll = {label: "", active: 'active'}
        vm.selectedPublicCategory = vm.displayAll
        vm.initialize()
      #====================================
      # Scope Management
      #====================================

      vm.appsFilter = (app) ->
        vm.currentSelectedCategory = if vm.publicPage then vm.selectedPublicCategory.label else vm.selectedCategory
        if (vm.searchTerm? && vm.searchTerm.length > 0) || !vm.currentSelectedCategory
          return true
        else
          return _.contains(app.categories, vm.currentSelectedCategory)

      vm.resetCategory = (category) ->
        vm.selectedPublicCategory.active = ''
        category.active = 'active'
        vm.selectedPublicCategory = category

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
            vm.publicCategories = _.map(response.categories, (c) -> {label: c, active: ''})
            vm.apps = response.apps
            if vm.publicPage
              vm.apps = _.filter(vm.apps, (app) -> _.includes(MnoeConfig.publicApplications(), app.nid))
      ).finally(-> vm.isLoading = false)

      $scope.$watch MnoeOrganizations.getSelectedId, (val) ->
        if val?
          vm.initialize()

      return
    })
