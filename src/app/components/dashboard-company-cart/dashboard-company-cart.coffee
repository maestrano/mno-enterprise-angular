
#============================================
#
#============================================
DashboardCompanyCartCtrl = ($scope, MnoeProvisioning) ->
  'ngInject'

  cartSubscriptions = ->
    params = { where: {staged_subscriptions: true } }
    MnoeProvisioning.getSubscriptions(params).then(
      (response) ->
        $scope.subscriptionsCount = response.length
    )
  cartSubscriptions()

  #====================================
  # Post-Initialization
  #====================================
  $scope.$watch MnoeProvisioning.getSubscriptionsPromise, (val) ->
    cartSubscriptions()

angular.module 'mnoEnterpriseAngular'
  .directive('dashboardCompanyCart', ->
    return {
      restrict: 'EA'
      controller: DashboardCompanyCartCtrl
      templateUrl: 'app/components/dashboard-company-cart/dashboard-company-cart.html',
    }
  )
