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

      # Calculate checkboxes
      vm.calculateChecked = () ->
        count = 0
        angular.forEach vm.apps, (value) ->
          if value.toCompare
            count++
          return
        count

      vm.compareValidation = () ->
        checkedApp = vm.calculateChecked()
        if (checkedApp > 4)
          toastr.error 'Need to select 2 to 4 items', 'Comparison'

      # Comparison function
      vm.comparison = (event) ->
        event.preventDefault()
        checkedApp = vm.calculateChecked()
        if (checkedApp > 4 || checkedApp < 2)
          toastr.error 'Need to select 2 to 4 items', 'Comparison'
        else
          $state.go('home.marketplace.compare')

      # Uncheck all checkboxes
      vm.uncheckAllApps = () ->
        angular.forEach(vm.apps, (items) ->
          items.toCompare = false
        )

      # Toggle compare block
      vm.compareToggle = () ->
        vm.showCompare = !vm.showCompare


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
