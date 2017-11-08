angular.module 'mnoEnterpriseAngular'
  .controller('ProvisioningConfirmCtrl', ($state, MnoeOrganizations, MnoeProvisioning, MnoeConfig) ->

    vm = this

    vm.isLoading = false
    vm.subscription = MnoeProvisioning.getSubscription()

    vm.validate = () ->
      vm.isLoading = true
      MnoeProvisioning.saveSubscription(vm.subscription).then(
        (response) ->
          MnoeProvisioning.setSubscription(response)
          $state.go('home.provisioning.order_summary')
      ).finally(-> vm.isLoading = false)

    MnoeOrganizations.get().then(
      (response) ->
        vm.orgCurrency = response.organization?.billing_currency || MnoeConfig.marketplaceCurrency()
    )

    return
  )
