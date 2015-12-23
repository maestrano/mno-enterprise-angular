angular.module 'mnoEnterpriseAngular'
  .controller 'ImpacController', ($scope, $log, MnoeOrganizations, ImpacDashboardsSvc) ->
    'ngInject'

    #====================================
    # Post-Initialization
    #====================================
    $scope.$watch MnoeOrganizations.getSelectedId, (val) ->
      if val?
        # Reload the dashboard
        ImpacDashboardsSvc.load(true)

    return
