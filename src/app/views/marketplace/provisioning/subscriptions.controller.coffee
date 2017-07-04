angular.module 'mnoEnterpriseAngular'
  .controller('ProvisioningSubscriptionsCtrl', ($stateParams, MnoeOrganizations, MnoeProvisioning) ->

    vm = this
    vm.isLoading = true

    MnoeOrganizations.get().then(
      (response) ->
        vm.orgCurrency = response.billing?.current?.options?.iso_code || 'USD'
    )

    MnoeProvisioning.getSubscriptions().then(
      (response) ->
        vm.subscriptions = response
    ).finally(-> vm.isLoading = false)

    return
  )
