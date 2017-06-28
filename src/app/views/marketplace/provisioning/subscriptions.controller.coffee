angular.module 'mnoEnterpriseAngular'
  .controller('ProvisioningSubscriptionsCtrl', ($stateParams, MnoeProvisioning) ->

    vm = this

    MnoeProvisioning.getProvisioning().then(
      ->
        vm.subscriptions = MnoeProvisioning.getSubscriptions()
    )

    return
  )
