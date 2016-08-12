angular.module 'mnoEnterpriseAngular'
  .controller 'ImpacController', ($scope, $log, MnoeOrganizations, ImpacDashboardsSvc, MnoeCurrentUser) ->
    'ngInject'

    MnoeCurrentUser.get().then(
      ->
        self.current_user_role = MnoeCurrentUser.user.organizations[0].current_user_role

      $scope.isAdminRole = ->
        self.current_user_role == 'Super Admin' || self.current_user_role == 'Admin'
    )

    #====================================
    # Post-Initialization
    #====================================
    $scope.$watch(MnoeOrganizations.getSelectedId, (newValue, oldValue) ->
      # Reload the dashboard
      ImpacDashboardsSvc.reload(true) if newValue? && oldValue? && newValue != oldValue
    )

    return
