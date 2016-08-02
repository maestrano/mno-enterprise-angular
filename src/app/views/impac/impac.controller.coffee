angular.module 'mnoEnterpriseAngular'
  .controller 'ImpacController', ($scope, $log, MnoeOrganizations, ImpacDashboardsSvc) ->
    'ngInject'

    #====================================
    # Post-Initialization
    #====================================

    # Triggers a dashboard reload with a loader spinner.
    reloadImpacDashboard = ->
      ImpacDashboardsSvc.triggerDhbLoader(true)
      ImpacDashboardsSvc.load(true).finally(->
        ImpacDashboardsSvc.triggerDhbLoader(false)
      )

    # Watches for organization selector drop-down change
    $scope.$watch(MnoeOrganizations.getSelectedId, (newValue, oldValue) ->
      reloadImpacDashboard() if newValue? && oldValue? && newValue != oldValue
    )

    return
