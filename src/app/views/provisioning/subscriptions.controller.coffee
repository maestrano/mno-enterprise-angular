angular.module 'mnoEnterpriseAngular'
  .controller('ProvisioningSubscriptionsCtrl', ($stateParams, MnoeOrganizations, MnoeProvisioning, MnoeConfig) ->

    vm = this
    vm.isLoading = true

    MnoeOrganizations.get().then(
      (response) ->
        vm.orgCurrency = response.billing?.current?.options?.iso_code || MnoeConfig.marketplaceCurrency()
    )

    MnoeProvisioning.getSubscriptions().then(
      (response) ->
        vm.subscriptions = response
    ).finally(-> vm.isLoading = false)

    return
  )
