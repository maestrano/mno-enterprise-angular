angular.module 'mnoEnterpriseAngular'
  .controller('DashboardMarketplaceCtrl', ($q, $scope, $stateParams, $state, toastr,
    MnoeMarketplace, PRICING_CONFIG, MARKETPLACE_CONFIG) ->

      vm = this

      #====================================
      # Initialization
      #====================================
      vm.isLoading = true
      vm.selectedCategory = ''
      vm.searchTerm = ''
      vm.isMarketplaceCompare = MARKETPLACE_CONFIG.compare.enabled
      vm.showCompare = false
      vm.nbAppsToCompare = 0

      #====================================
      # Scope Management
      #====================================
      vm.linkFor = (app) ->
        "#/marketplace/#{app.id}"

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

      MnoeMarketplace.getApps().then(
        (response) ->
          # Remove restangular decoration
          response = response.plain()

          vm.categories = response.categories
          vm.apps = response.apps

          vm.isLoading = false

      )

      return
  )
