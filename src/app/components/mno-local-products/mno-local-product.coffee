angular.module 'mnoEnterpriseAngular'
  .controller('mnoLocalProduct', ($scope, $stateParams, $state, isPublic, parentState, MnoeMarketplace, MnoeOrganizations, MnoeConfig) ->

    vm = this
    vm.isPublic = isPublic
    vm.parentState = parentState

    vm.isPriceShown = if vm.isPublic
    then MnoeConfig.isMarketplacePricingEnabled()
    else MnoeConfig.isPublicPricingEnabled()

    vm.isProvisioningEnabled = !vm.isPublic && MnoeConfig.isProvisioningEnabled()

    vm.isLoading = true


    # Retrieve the products
    vm.initialize = ->
      MnoeMarketplace.getApps().then(
        (response) ->
          vm.products = _.filter(response.products, (product) -> product.local)
          if !vm.isPublic
            organization = MnoeOrganizations.get().then((response) -> response.organization)
            vm.orgCurrency = organization.organization?.billing_currency || MnoeConfig.marketplaceCurrency()
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
