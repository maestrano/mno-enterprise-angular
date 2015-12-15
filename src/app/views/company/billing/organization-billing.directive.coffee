DashboardOrganizationBillingCtrl = ($scope, $window, DhbOrganizationSvc, Utilities, Miscellaneous) ->
  #====================================
  # Pre-Initialization
  #====================================
  $scope.isLoading = true
  $scope.billing = {}

  #====================================
  # Scope Management
  #====================================
  # Initialize the data used by the directive
  $scope.initialize = (billing) ->
    angular.copy(billing,$scope.billing)
    $scope.isLoading = false

  $scope.isCreditShown = () ->
    b = $scope.billing
    b &&
    b.credit &&
    b.credit.value > 0

  #====================================
  # Post-Initialization
  #====================================
  $scope.$watch DhbOrganizationSvc.getId, (val) ->
    $scope.isLoading = true
    if val?
      DhbOrganizationSvc.load().then (organization)->
        $scope.initialize(organization.billing)


angular.module 'mnoEnterpriseAngular'
  .directive('dashboardOrganizationBilling', ->
    return {
      restrict: 'A',
      scope: {
      },
      templateUrl: 'app/views/company/billing/organization-billing.html',
      controller: DashboardOrganizationBillingCtrl
    }
  )
