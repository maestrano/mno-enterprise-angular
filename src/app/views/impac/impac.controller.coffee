angular.module 'mnoEnterpriseAngular'
  .controller 'ImpacController', ($scope, $log, MnoeOrganizations, ImpacDashboardsSvc) ->
    'ngInject'

    #====================================
    # Post-Initialization
    #====================================
    $scope.$watch MnoeOrganizations.getSelectedId, (newValue, oldValue) ->
      if newValue? && oldValue?
        console.log "Reload with id", newValue

        # Reload the dashboard
        ImpacDashboardsSvc.load(true)

    return
