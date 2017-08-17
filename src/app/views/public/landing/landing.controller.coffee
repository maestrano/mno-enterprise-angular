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

      vm.carouselImage = (app) ->
        {
          "background-image": "url(#{app.pictures[0]})"
        }

      MnoeMarketplace.getApps().then(
        (response) ->
          vm.apps = response.apps
          vm.categories = response.categories
      )

      return
  )
