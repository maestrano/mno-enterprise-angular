
DashboardOrganizationInvoicesCtrl = ($scope, $window, MnoeOrganizations, DASHBOARD_CONFIG) ->
  'ngInject'

  #====================================
  # Pre-Initialization
  #====================================
  $scope.isLoading = true
  $scope.invoices = []
  $scope.payment_enabled = DASHBOARD_CONFIG.payment?.enabled

  #====================================
  # Post-Initialization
  #====================================
  $scope.$watch MnoeOrganizations.getSelected, (val) ->
    if val?
      $scope.invoices = MnoeOrganizations.selected.invoices


angular.module 'mnoEnterpriseAngular'
  .directive('dashboardOrganizationInvoices', ->
    return {
      restrict: 'A',
      scope: {
      },
      templateUrl: 'app/views/company/invoices/organization-invoices.html',
      controller: DashboardOrganizationInvoicesCtrl
    }
  )
