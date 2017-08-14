angular.module 'mnoEnterpriseAngular'
  .controller('LandingCtrl',
    ($scope, $rootScope, $state, $stateParams, MnoeMarketplace) ->
      vm = @
      $rootScope.publicPage = true

      MnoeMarketplace.getApps().then(
        (response) ->
          vm.apps = response.apps
      )

      return
  )
