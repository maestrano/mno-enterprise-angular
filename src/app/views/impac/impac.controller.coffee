angular.module 'mnoEnterpriseAngular'
  .controller 'ImpacController', ($scope, $state, MnoeOrganizations, ImpacDashboardsSvc) ->
    'ngInject'

    vm = this

    #====================================
    # Post-Initialization
    #====================================
    $scope.$watch(MnoeOrganizations.getSelectedId, (newValue, oldValue) ->
      vm.isLoaded = false

      # Reload the dashboard
      ImpacDashboardsSvc.reload(true) if newValue? && oldValue? && newValue != oldValue

      # Fetch current organization to check if user is allowed
      MnoeOrganizations.get().then(
        ->
          # Impac is displayed only to admin and super admin
          vm.isImpacShown = (MnoeOrganizations.role.isAdmin() || MnoeOrganizations.role.isSuperAdmin())

          # The user is not allowed to se impac, he is redirected
          if !vm.isImpacShown
            $state.go('home.login')

          vm.isLoaded = true
      ) if newValue?
    )

    return
