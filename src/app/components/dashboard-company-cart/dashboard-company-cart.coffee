
#============================================
#
#============================================
DashboardCompanyCartCtrl = ($scope, MnoeProvisioning, MnoeOrganizations) ->
  'ngInject'

  cartSubscriptions = ->
    params = { where: {subscription_status_in: 'staged' } }
    MnoeProvisioning.getSubscriptions(params, true).then(
      (response) ->
        $scope.subscriptionsCount = response.length
    )

  #====================================
  # Post-Initialization
  #====================================
  $scope.$watch MnoeOrganizations.getSelected, (val) ->
    $scope.subscriptionsCount = 0
    if MnoeProvisioning.cartSubscriptionsPromise
      MnoeProvisioning.emptyCartSubscriptions()
    else
      cartSubscriptions()

  $scope.$watch MnoeProvisioning.getCartSubscriptionsPromise, (val) ->
    cartSubscriptions()

angular.module 'mnoEnterpriseAngular'
  .directive('dashboardCompanyCart', ->
    return {
      restrict: 'EA'
      controller: DashboardCompanyCartCtrl
      templateUrl: 'app/components/dashboard-company-cart/dashboard-company-cart.html',
    }
  )
