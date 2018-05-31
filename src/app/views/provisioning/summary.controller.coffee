angular.module 'mnoEnterpriseAngular'
  .controller('ProvisioningSummaryCtrl', ($scope, $state, $stateParams, MnoeOrganizations, MnoeProvisioning, MnoeConfig) ->

    vm = this
    vm.isLoading = true
    vm.selectedCurrency = MnoeProvisioning.getSelectedCurrency()
    MnoeProvisioning.initSubscription({subscriptionId: $stateParams.subscriptionId})
      .then((response) ->
        vm.subscription = response
        vm.singleBilling = vm.subscription.product.single_billing_enabled
        vm.billedLocally = vm.subscription.product.billed_locally
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

    return
  )
