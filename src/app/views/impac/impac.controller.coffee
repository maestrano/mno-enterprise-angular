angular.module 'mnoEnterpriseAngular'
  .controller 'ImpacController', ($scope, $state, MnoeOrganizations, DOCK_CONFIG) ->
    'ngInject'

    vm = this
    vm.isDockEnabled = DOCK_CONFIG.enabled

    #====================================
    # Post-Initialization
    #====================================
    $scope.$watch(MnoeOrganizations.getSelectedId, (newValue) ->
      vm.isImpacShown = true

      # Fetch current organization to check if user is allowed
      MnoeOrganizations.get().then(
        ->
          # Impac is displayed only to admin and super admin
          vm.isImpacShown = MnoeOrganizations.role.atLeastAdmin()
          $state.go('home.login') unless vm.isImpacShown

      ) if newValue?
    )

    return
