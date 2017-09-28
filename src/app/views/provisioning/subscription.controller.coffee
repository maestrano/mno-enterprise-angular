angular.module 'mnoEnterpriseAngular'
  .controller('ProvisioningSubscriptionCtrl', ($stateParams, MnoeMarketplace) ->

    vm = this
    vm.isLoading = true
    vm.subscription = $stateParams.subscription
    
    if vm.subscription.custom_data?
      MnoeMarketplace.findProduct(id: vm.subscription.product_id).then((response) ->
        vm.schema = JSON.parse(response.custom_schema)
        vm.isLoading = false
      )
    else
      vm.isLoading = false

    vm.formatPrice = (price) ->
      vm.price = price.currency + (price.price_cents / 100)

    return
  )
