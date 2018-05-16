
#============================================
#
#============================================
DashboardCompanyCartCtrl = ($scope, MnoeProvisioning) ->
  'ngInject'

  cartSubscriptions = ->
    params = { where: {status_for: 'staged' } }
    MnoeProvisioning.getSubscriptions(params, true).then(
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
