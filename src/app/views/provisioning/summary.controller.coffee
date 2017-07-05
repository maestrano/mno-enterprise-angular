angular.module 'mnoEnterpriseAngular'
  .controller('ProvisioningSummaryCtrl', (MnoeOrganizations, MnoeProvisioning) ->

    vm = this

    vm.subscription = MnoeProvisioning.getSubscription()

    MnoeOrganizations.get().then(
      (response) ->
        vm.orgCurrency = response.billing?.current?.options?.iso_code || 'USD'
    )

    return
  )
