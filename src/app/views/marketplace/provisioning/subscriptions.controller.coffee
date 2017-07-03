angular.module 'mnoEnterpriseAngular'
  .controller('ProvisioningSubscriptionsCtrl', ($stateParams, MnoeProvisioning) ->

    vm = this
    vm.isLoading = true

    MnoeProvisioning.getSubscriptions().then(
      (response) ->
        vm.subscriptions = response
    ).finally(-> vm.isLoading = false)

    return
  )
