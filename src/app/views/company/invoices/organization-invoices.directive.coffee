
DashboardOrganizationInvoicesCtrl = ($scope, $window, DhbOrganizationSvc, Utilities, Miscellaneous) ->
  #====================================
  # Pre-Initialization
  #====================================
  $scope.isLoading = true
  $scope.invoices = []

  #====================================
  # Scope Management
  #====================================
  # Initialize the data used by the directive
  $scope.initialize = (invoices) ->
    angular.copy(invoices,$scope.invoices)
    $scope.isLoading = false

  #====================================
  # Post-Initialization
  #====================================
  $scope.$watch DhbOrganizationSvc.getId, (val) ->
    $scope.isLoading = true
    if val?
      DhbOrganizationSvc.load().then (organization)->
        $scope.initialize(organization.invoices)


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
