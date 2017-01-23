angular.module 'mnoEnterpriseAngular'
  .controller('DashboardMarketplaceCompareCtrl', (MnoeMarketplace, toastr, $scope, greeting) ->
    'ngInject'

    vm = this
    vm.greeting = greeting

    #====================================
    # Initialization
    #====================================
    vm.isLoading = true

    vm.checkedCount = ->
      vm.apps.filter((app) ->
        app.is_responsive
      ).length
      toastr.pop('info', "title", "text")

    #====================================
    # Calls
    #====================================
    MnoeMarketplace.getApps().then(
      (response) ->
        # Remove restangular decoration
        response = response.plain()

        vm.categories = response.categories
        vm.apps = response.apps
        vm.pricing_plans = response.pricing_plans

        vm.isLoading = false
    )

    return
  )
