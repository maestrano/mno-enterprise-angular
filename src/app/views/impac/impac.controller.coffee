angular.module 'mnoEnterpriseAngular'
  .controller 'ImpacController', ($scope, $state, ImpacDashboardsSvc, MnoeCurrentUser, MnoeOrganizations, DOCK_CONFIG) ->
    'ngInject'

    vm = this
    vm.isImpacShown = false
    vm.isDockEnabled = DOCK_CONFIG.enabled

    #====================================
    # Post-Initialization
    #====================================
    $scope.$watch(MnoeOrganizations.getSelectedId, (newValue, oldValue) ->
      MnoeCurrentUser.get().then(
        (response) ->
          selectedOrg = _.find(response.organizations, {id: newValue})
          # Needs to be at least admin to display impac! or user is redirected to apps dashboard
          if MnoeOrganizations.role.atLeastAdmin(selectedOrg.current_user_role)
            # Display impac! and force it to reload if necessary
            vm.isImpacShown = true
            ImpacDashboardsSvc.reload(true) if newValue? && oldValue? && newValue != oldValue
          else
            $state.go('home.apps')
      ) if newValue?
    )

    return
