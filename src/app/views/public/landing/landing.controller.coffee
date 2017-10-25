angular.module 'mnoEnterpriseAngular'
  .controller('LandingCtrl',
    ($scope, $rootScope, $state, $stateParams, $window, $translate, MnoeConfig, MnoeMarketplace, URI) ->

      vm = @
      vm.isLoading = true

      vm.appsFilter = (app) ->
        if (vm.searchTerm? && vm.searchTerm.length > 0) || !vm.selectedCategory
          return true
        else
          return _.contains(app.categories, vm.selectedCategory)

      vm.carouselImageStyle = (app) ->
        {
          "background-image": "url(#{app.pictures[0]})"
        }

      MnoeMarketplace.getApps().then(
        (response) ->
          vm.apps = _.filter(response.apps, (app) -> _.includes(MnoeConfig.publicApplications(), app.nid))
          vm.highlightedApps = _.filter(response.apps, (app) -> _.includes(MnoeConfig.publicHighlightedApplications(), app.nid))
          vm.categories = response.categories
      ).finally(-> vm.isLoading = false)

      return
  )
