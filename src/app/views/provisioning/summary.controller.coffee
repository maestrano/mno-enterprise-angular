angular.module 'mnoEnterpriseAngular'
  .controller('ProvisioningSummaryCtrl', ($scope, MnoeOrganizations, MnoeProvisioning, MnoeConfig) ->

    vm = this

    vm.subscription = MnoeProvisioning.getSubscription()

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
