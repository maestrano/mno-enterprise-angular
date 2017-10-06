angular.module 'mnoEnterpriseAngular'
  .controller('ProvisioningSubscriptionCtrl', ($stateParams, MnoeProvisioning, MnoeMarketplace) ->

    vm = this
    vm.isLoading = true

    MnoeProvisioning.fetchSubscription($stateParams.id).then(
      (response) ->
        vm.subscription = response

        if vm.subscription.custom_data?
          MnoeMarketplace.findProduct(id: vm.subscription.product_id).then(
            (response) ->
              vm.schema = JSON.parse(response.custom_schema)
          )
    ).finally(-> vm.isLoading = false)

    return
  )
