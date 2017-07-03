angular.module 'mnoEnterpriseAngular'
  .controller('ProvisioningConfirmCtrl', ($state, MnoeOrganizations, MnoeProvisioning) ->

    vm = this

    vm.isLoading = false
    vm.product = MnoeProvisioning.getCurrentProduct()
    vm.selectedPricingPlan = MnoeProvisioning.getPricingPlan()

    vm.validate = () ->
      vm.isLoading = true
      MnoeProvisioning.createSubscription().then(
        (response) ->
          $state.go('home.provisioning.confirm')
      ).finally(-> vm.isLoading = false)

    MnoeOrganizations.get().then(
      (response) ->
        vm.orgCurrency = response.billing?.current?.options?.iso_code || 'USD'
    )

    return
  )
