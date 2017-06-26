
DashboardOrganizationInvoicesCtrl = ($scope, $window, MnoeOrganizations, MnoeConfig) ->
  'ngInject'

  #====================================
  # Pre-Initialization
  #====================================
  $scope.isLoading = true
  $scope.invoices = []
  $scope.payment_enabled = MnoeConfig.isPaymentEnabled()

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
