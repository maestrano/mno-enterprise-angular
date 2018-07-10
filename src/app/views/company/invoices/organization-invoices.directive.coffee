
DashboardOrganizationInvoicesCtrl = ($scope, $window, MnoeOrganizations, MnoeInvoices, MnoeConfig) ->
  'ngInject'

  #====================================
  # Pre-Initialization
  #====================================
  $scope.isLoading = true
  $scope.invoices = {
    list: [],
    sort: 'ended_at.desc',
    nbItems: 10,
    page:1,
    pageChangedCb: (nbItems, page) ->
      $scope.invoices.nbItems = nbItems
      $scope.invoices.page = page
      $scope.invoices.offset = (page  - 1) * nbItems
      fetchInvoices(nbItems, $scope.invoices.offset)

  }
  $scope.payment_enabled = MnoeConfig.isPaymentEnabled()

  fetchInvoices = (limit, offset, sort = $scope.invoices.sort ) ->
    $scope.invoices.loading = true
    MnoeInvoices.getInvoices(limit, offset, sort).then(
      (response) ->
        $scope.invoices.list = response.data
        $scope.invoices.totalItems = response.headers('x-total-count')
    ).finally(->
      $scope.invoices.loading = false
    )

  #====================================
  # Post-Initialization
  #====================================
  $scope.$watch MnoeOrganizations.getSelected, (val) ->
    if val?
      fetchInvoices($scope.invoices.nbItems,0)


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
