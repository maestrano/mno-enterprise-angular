angular.module 'mnoEnterpriseAngular'
  .controller('ProvisioningSummaryCtrl', ($scope, $state, $stateParams, MnoeOrganizations, MnoeProvisioning, MnoeConfig) ->

    vm = this
    vm.isLoading = true
    vm.quoteBased = false
    vm.quote = {}
    vm.selectedCurrency = MnoeProvisioning.getSelectedCurrency()
    vm.subType = if $stateParams.cart == 'true' then 'cart' else 'active'

    MnoeProvisioning.initSubscription({subscriptionId: $stateParams.subscriptionId})
      .then((response) ->
        vm.subscription = response
        vm.singleBilling = vm.subscription.product.single_billing_enabled
        vm.billedLocally = vm.subscription.product.billed_locally
        vm.quoteBased = vm.subscription.product_pricing.quote_based
        vm.quote = MnoeProvisioning.getCachedQuote() if vm.quoteBased
        )
      .finally(() -> vm.isLoading = false)

    vm.orderTypeText = 'mno_enterprise.templates.dashboard.provisioning.subscriptions.' + $stateParams.editAction.toLowerCase()

    MnoeOrganizations.get().then(
      (response) ->
        vm.orgCurrency = response.organization?.billing_currency || MnoeConfig.marketplaceCurrency()
    )

    # Delete the cached subscription.
    $scope.$on('$stateChangeStart', (event, toState) ->
      MnoeProvisioning.setSubscription({})
    )

    vm.pricingText = () ->
      if !vm.singleBilling
        'mno_enterprise.templates.dashboard.provisioning.summary.pricing_info.single_billing_disabled'
      else if vm.billedLocally
        'mno_enterprise.templates.dashboard.provisioning.summary.pricing_info.billed_locally'
      else
        'mno_enterprise.templates.dashboard.provisioning.summary.pricing_info.externally_managed'

    return
  )
