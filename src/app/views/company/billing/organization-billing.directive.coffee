DashboardOrganizationBillingCtrl = ($scope, $window, MnoeOrganizations, Utilities, Miscellaneous) ->

  #====================================
  # Scope Management
  #====================================
  $scope.isCreditShown = () ->
    b = $scope.billing
    b &&
    b.credit &&
    b.credit.value > 0

  #====================================
  # Post-Initialization
  #====================================
  $scope.$watch MnoeOrganizations.getSelected, (val) ->
    $scope.isLoading = true
    if val?
      $scope.billing = MnoeOrganizations.selected.billing


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
