#============================================
#
#============================================
angular.module 'mnoEnterpriseAngular'
  .controller('DashboardMarketplaceProductCtrl',($scope, $q, $stateParams, $state, MnoeMarketplace, MnoeOrganizations, MnoeConfig, MnoeCurrentUser) ->

    vm = this

    vm.isPriceShown = MnoeConfig.isMarketplacePricingEnabled()
    vm.isLoading = true

    atLeastAdmin = (user, currentOrg) ->
      org = _.find(user.organizations, { id: currentOrg.organization?.id })
      console.log 'MnoeOrganizations.role.atLeastAdmin(org.current_user_role)'
      console.log MnoeOrganizations.role.atLeastAdmin(org.current_user_role)
      MnoeOrganizations.role.atLeastAdmin(org.current_user_role)

    # Retrieve the products
    vm.initialize = ->
      $q.all({
        organization: MnoeOrganizations.get(),
        localProducts: MnoeMarketplace.getLocalProducts(),
        currentUser: MnoeCurrentUser.get()
      }).then(
        (response) ->
          products = response.localProducts
          organization = response.organization

          vm.orgCurrency = organization.organization?.billing_currency || MnoeConfig.marketplaceCurrency()
          vm.isProvisioningEnabled = MnoeConfig.isProvisioningEnabled() && atLeastAdmin(response.currentUser, organization)

          # App to be displayed
          productId = $stateParams.productId
          vm.product = _.findWhere(products, { nid: productId })
          vm.product ||= _.findWhere(products, { id:  productId })

          $state.go('home.marketplace') unless vm.product?
      ).finally(-> vm.isLoading = false)

    vm.planAvailableForCurrency = (plan) ->
      _.includes(_.map(plan.prices, 'currency'), vm.orgCurrency)

    #====================================
    # Post-Initialization
    #====================================
    $scope.$watch MnoeOrganizations.getSelectedId, (val) ->
      if val?
        vm.isLoading = true
        vm.initialize()

    return
  )
