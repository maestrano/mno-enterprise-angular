angular.module 'mnoEnterpriseAngular'
  .controller('LandingCtrl',
    ($scope, $rootScope, $state, $stateParams, MnoeMarketplace) ->
      vm = @
      $rootScope.publicPage = true

      vm.appsFilter = (app) ->
        if (vm.searchTerm? && vm.searchTerm.length > 0) || !vm.selectedCategory
          return true
        else
          return _.contains(app.categories, vm.selectedCategory)

      MnoeMarketplace.getApps().then(
        (response) ->
          vm.apps = response.apps
          vm.categories = response.categories
      )

      return
  )
