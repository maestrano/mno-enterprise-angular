angular.module 'mnoEnterpriseAngular'
  .controller('DashboardMarketplaceCtrl', (MnoeMarketplace) ->
    'ngInject'

    vm = this

    #====================================
    # Initialization
    #====================================
    vm.isLoading = true
    vm.selectedCategory = ''
    vm.searchTerm = ''

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

    #====================================
    # Calls
    #====================================
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
