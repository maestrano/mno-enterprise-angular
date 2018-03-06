angular.module 'mnoEnterpriseAngular'
  .controller('LandingCtrl',
    ($scope, $rootScope, $state, $stateParams, $window, MnoeConfig, MnoeMarketplace, URI) ->

      vm = @
      vm.isLoading = true
      vm.displayAll = {label: "", active: 'active'}
      vm.selectedCategory = vm.displayAll
      vm.appsFilter = (app) ->
        if (vm.searchTerm? && vm.searchTerm.length > 0) || !vm.selectedCategory.label
          return true
        else
          return _.contains(app.categories, vm.selectedCategory.label)

      vm.carouselImageStyle = (app) ->
        {
          "background-image": "url(#{app.pictures[0]})"
        }

      vm.updateCategory = (category) ->
        vm.selectedCategory.active = ''
        category.active = 'active'
        vm.selectedCategory = category

      MnoeMarketplace.getApps().then(
        (response) ->
          vm.apps = _.filter(response.apps, (app) -> _.includes(MnoeConfig.publicApplications(), app.nid))
          vm.highlightedApps = _.filter(response.apps, (app) -> _.includes(MnoeConfig.publicHighlightedApplications(), app.nid))
          vm.categories = _.map(response.categories, (c) -> {label: c, active: ''})
      ).finally(-> vm.isLoading = false)

      return
  )
