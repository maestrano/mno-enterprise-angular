angular.module 'mnoEnterpriseAngular'
  .controller 'ImpacController', ($scope, $log, MnoeOrganizations, ImpacDashboardsSvc) ->
    'ngInject'

    #====================================
    # Post-Initialization
    #====================================
    $scope.$watch(MnoeOrganizations.getSelectedId, (newValue, oldValue) ->
      # Reload the dashboard
      ImpacDashboardsSvc.reload(true) if newValue? && oldValue? && newValue != oldValue
    )

    return
