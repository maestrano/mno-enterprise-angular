angular.module 'mnoEnterpriseAngular'
  .controller 'ImpacController', ($scope, $state, MnoeOrganizations, ImpacDashboardsSvc, DOCK_CONFIG) ->
    'ngInject'

    vm = this
    $scope.isDockEnabled = DOCK_CONFIG.enabled

    #====================================
    # Post-Initialization
    #====================================
    $scope.$watch(MnoeOrganizations.getSelectedId, (newValue) ->
      vm.isLoaded = false
      vm.isImpacShown = false

      # Fetch current organization to check if user is allowed
      MnoeOrganizations.get().then(
        ->
          # Impac is displayed only to admin and super admin
          vm.isImpacShown = (MnoeOrganizations.role.isAdmin() || MnoeOrganizations.role.isSuperAdmin())

          if !vm.isImpacShown
            $state.go('home.login')

          vm.isLoaded = true
      ) if newValue?
    )

    return
