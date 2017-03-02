
DashboardOrganizationInvoicesCtrl = ($scope, $window, MnoeOrganizations, PAYMENT_CONFIG) ->
  'ngInject'

  #====================================
  # Pre-Initialization
  #====================================
  $scope.isLoading = true
  $scope.invoices = []
  $scope.payment_enabled = not PAYMENT_CONFIG.disabled

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
