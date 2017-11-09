angular.module 'mnoEnterpriseAngular'
  .controller('ProvisioningSummaryCtrl', (MnoeOrganizations, MnoeProvisioning, MnoeConfig) ->

    vm = this

    vm.subscription = MnoeProvisioning.getSubscription()

    MnoeOrganizations.get().then(
      (response) ->
        vm.orgCurrency = response.organization?.billing_currency || MnoeConfig.marketplaceCurrency()
    )

    return
  )
