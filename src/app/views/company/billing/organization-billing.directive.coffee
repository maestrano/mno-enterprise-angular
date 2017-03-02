DashboardOrganizationBillingCtrl = ($scope, $window, MnoeOrganizations, PAYMENT_CONFIG) ->
  'ngInject'

  #====================================
  # Scope Management
  #====================================
  $scope.isCreditShown = () ->
    b = $scope.billing
    b &&
    b.credit &&
    b.credit.value > 0
  $scope.payment_enabled = not PAYMENT_CONFIG.disabled

  #====================================
  # Post-Initialization
  #====================================
  $scope.$watch MnoeOrganizations.getSelected, (val) ->
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
