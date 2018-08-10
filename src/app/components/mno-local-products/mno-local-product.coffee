angular.module 'mnoEnterpriseAngular'
  .controller('mnoLocalProduct', ($scope, $stateParams, $state, isPublic, parentState, MnoeMarketplace, MnoeOrganizations, MnoeConfig, MnoeCurrentUser, ProvisioningHelper) ->

    vm = this
    vm.isPublic = isPublic
    vm.parentState = parentState

    vm.isPriceShown = if vm.isPublic
    then MnoeConfig.isPublicPricingEnabled()
    else MnoeConfig.isMarketplacePricingEnabled()

    vm.isProvisioningEnabled = !vm.isPublic && MnoeConfig.isProvisioningEnabled()
    vm.canProvision = false
    vm.buttonDisabledTooltip = ''

    vm.isLoading = true

    atLeastAdmin = (user, currentOrg) ->
      org = _.find(user.organizations, { id: currentOrg.id })
      MnoeOrganizations.role.atLeastAdmin(org.current_user_role)

    vm.pricedPlan = ProvisioningHelper.pricedPlan

    vm.planAvailableForCurrency = (plan) ->
      _.includes(_.map(plan.prices, 'currency'), vm.orgCurrency)

    vm.hideNoPricingFound = (plan) ->
      vm.isPublic || vm.planAvailableForCurrency(plan) || !vm.pricedPlan(plan)

    vm.buttonDisabled = () ->
      !vm.canProvision || !vm.orderPossible

    vm.updateButtonDisabledTooltip = () ->
      if !vm.canProvision
        'mno_enterprise.templates.components.app_install_btn.insufficient_privilege'
      else if !vm.orderPossible
        'mno_enterprise.templates.dashboard.marketplace.show.no_pricing_plans_found_tooltip'

    # Retrieve the products
    vm.initialize = ->
      MnoeMarketplace.getApps().then(
        (response) ->
          vm.products = _.filter(response.products, 'local')
          if !vm.isPublic
            organization = MnoeOrganizations.selected.organization
            currentUser = MnoeCurrentUser.user
            vm.orgCurrency = organization.billing_currency || MnoeConfig.marketplaceCurrency()
            vm.canProvision = atLeastAdmin(currentUser, organization)
          else
            vm.orgCurrency = MnoeConfig.marketplaceCurrency()

          # App to be displayed
          productId = $stateParams.productId
          vm.product = _.findWhere(vm.products, { nid: productId })
          vm.product ||= _.findWhere(vm.products, { id: productId })

          # Plans
          plans = vm.product.pricing_plans
          # Is currency selection enabled
          currencySelection = MnoeConfig.isCurrencySelectionEnabled()
          # Are there any available plans
          availablePlans = ProvisioningHelper.plansForCurrency(plans, vm.orgCurrency)

          # We can order if there's an availablePlan for the currency
          # Or if the currency selection is enabled and we have a priced plan
          vm.orderPossible = !_.isEmpty(availablePlans) ||
            (currencySelection && _.some(plans, (plan) -> ProvisioningHelper.pricedPlan(plan) && plan.prices?))

          vm.buttonDisabledTooltip = vm.updateButtonDisabledTooltip()

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
