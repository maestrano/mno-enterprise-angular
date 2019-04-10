
DashboardOrganizationInvoicesCtrl = ($scope, $window, MnoeOrganizations, MnoeInvoices, MnoeConfig) ->
  'ngInject'

  #====================================
  # Pre-Initialization
  #====================================
  $scope.isLoading = true
  #$scope.invoices = []
  $scope.invoices =
      list: []
      nbItems: 10
      sort: "ended_at.desc"
      page: 1
      offset: 0
      pageChangedCb: (nbItems, page) ->
          $scope.invoices.nbItems = nbItems
          $scope.invoices.page = page
          $scope.invoices.offset = (page  - 1) * nbItems
          fetchInvoices(nbItems, $scope.invoices.offset)
  $scope.payment_enabled = MnoeConfig.isPaymentEnabled()

  fetchInvoices = (limit, offset) ->
    $scope.invoices.loading = true
    return MnoeInvoices.list(limit, offset).then(
      (response) ->
        $scope.invoices.totalItems = response.headers('x-total-count')
        $scope.invoices.list = response.data
    ).finally(-> $scope.invoices.loading = false)

  #====================================
  # Post-Initialization
  #====================================
  $scope.$watch MnoeOrganizations.getSelected, (val) ->
    if val?
      fetchInvoices($scope.invoices.nbItems,$scope.invoices.offset)

  


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
