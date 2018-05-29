
#============================================
#
#============================================
DashboardCompanyCartCtrl = ($scope, MnoeProvisioning, MnoeOrganizations, MnoeCurrentUser) ->
  'ngInject'

  initCartSubscritpions = ->
    params = { where: {subscription_status_in: 'staged' } }
    MnoeProvisioning.getSubscriptions(params, true).then(
      (response) ->
        $scope.subscriptionsCount = response.length
    )

  cartSubscriptions = ->
    organization = MnoeOrganizations.getSelected()?.organization
    MnoeCurrentUser.get().then(
      (response) ->
        org = _.find(response.organizations, { id: organization.id })
        if MnoeOrganizations.role.atLeastAdmin(org.current_user_role)
          initCartSubscritpions()
    )
  cartSubscriptions()

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
