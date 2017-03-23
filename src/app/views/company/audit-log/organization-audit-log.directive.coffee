DashboardOrganizationAuditLogCtrl = ($scope, MnoeAuditEvents) ->
  'ngInject'

  #====================================
  # Pre-Initialization
  #====================================
  $scope.isLoading = true
  $scope.exportUrl = MnoeAuditEvents.exportUrl()

angular.module 'mnoEnterpriseAngular'
  .directive('dashboardOrganizationAuditLog', ->
    return {
      restrict: 'A',
      scope: {
      },
      templateUrl: 'app/views/company/audit-log/organization-audit-log.html',
      controller: DashboardOrganizationAuditLogCtrl
    }
  )
