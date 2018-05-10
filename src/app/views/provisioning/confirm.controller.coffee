angular.module 'mnoEnterpriseAngular'
  .controller('ProvisioningConfirmCtrl', ($scope, $stateParams, $state, MnoeOrganizations, MnoeProvisioning, MnoeAppInstances, MnoeConfig) ->

    vm = this

    vm.isLoading = false
    vm.subscription = MnoeProvisioning.getSubscription()
    vm.singleBilling = vm.subscription.product.single_billing_enabled
    vm.billedLocally = vm.subscription.product.billed_locally

    # Happens when the user reload the browser during the provisioning workflow.
    if _.isEmpty(vm.subscription)
      # Redirect the user to the first provisioning screen
      $state.go('home.provisioning.order', {id: $stateParams.id, nid: $stateParams.nid, cart: $stateParams.cart}, {reload: true})

    vm.editOrder = () ->
      $state.go('home.provisioning.order', {id: $stateParams.id, nid: $stateParams.nid, cart: $stateParams.cart})


    vm.validate = () ->
      vm.isLoading = true
      vm.subscription.cart_entry = true if $stateParams.cart
      MnoeProvisioning.saveSubscription(vm.subscription).then(
        (response) ->
          MnoeProvisioning.setSubscription(response)
          # Reload dock apps
          MnoeAppInstances.getAppInstances().then(
            (response) ->
              $scope.apps = response
          )
          $state.go('home.provisioning.order_summary', {id: $stateParams.id, nid: $stateParams.nid, cart: $stateParams.cart})
      ).finally(-> vm.isLoading = false)

    vm.addToCart = ->
      vm.isLoading = true
      vm.subscription.cart_entry = true
      MnoeProvisioning.saveSubscription(vm.subscription).then(
        (response) ->
          MnoeProvisioning.refreshSubscriptions()
          $state.go('home.marketplace')
      ).finally(-> vm.isLoading = false)

    MnoeOrganizations.get().then(
      (response) ->
        vm.orgCurrency = response.organization?.billing_currency || MnoeConfig.marketplaceCurrency()
    )

    # Delete the cached subscription when we are leaving the subscription workflow.
    $scope.$on('$stateChangeStart', (event, toState) ->
      switch toState.name
        when "home.provisioning.order", "home.provisioning.order_summary", "home.provisioning.additional_details"
          null
        else
          MnoeProvisioning.setSubscription({})
    )

    return
  )
