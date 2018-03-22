angular.module 'mnoEnterpriseAngular'
  .controller('mnoLocalProduct', ($scope, $stateParams, $state, isPublic, parentState, MnoeMarketplace, MnoeOrganizations, MnoeConfig, MnoeCurrentUser) ->

    vm = this
    vm.isPublic = isPublic
    vm.parentState = parentState

    vm.isPriceShown = if vm.isPublic
    then MnoeConfig.isPublicPricingEnabled()
    else MnoeConfig.isMarketplacePricingEnabled()

    vm.isProvisioningEnabled = !vm.isPublic && MnoeConfig.isProvisioningEnabled()

    vm.isLoading = true

    atLeastAdmin = (user, currentOrg) ->
      org = _.find(user.organizations, { id: currentOrg.id })
      MnoeOrganizations.role.atLeastAdmin(org.current_user_role)

    # Retrieve the products
    vm.initialize = ->
      MnoeMarketplace.getApps().then(
        (response) ->
          vm.products = _.filter(response.products, 'local')
          if !vm.isPublic
            organization = MnoeOrganizations.selected.organization
            currentUser = MnoeCurrentUser.user
            vm.orgCurrency = organization.billing_currency || MnoeConfig.marketplaceCurrency()
            vm.isProvisioningEnabled = vm.isProvisioningEnabled && atLeastAdmin(currentUser, organization)
            vm.planAvailableForCurrency = (plan) ->
              _.includes(_.map(plan.prices, 'currency'), vm.orgCurrency)

          # App to be displayed
          productId = $stateParams.productId
          vm.product = _.findWhere(vm.products, { nid: productId })
          vm.product ||= _.findWhere(vm.products, { id: productId })
          $state.go(vm.parentState) unless vm.product?
      ).finally(-> vm.isLoading = false)

    #====================================
    # Post-Initialization
    #====================================
    $scope.$watch MnoeOrganizations.getSelectedId, (val) ->
      if val?
        vm.isLoading = true
        vm.initialize()

    vm.initialize()

    return
  )
