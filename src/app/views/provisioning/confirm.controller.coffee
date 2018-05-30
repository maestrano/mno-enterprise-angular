angular.module 'mnoEnterpriseAngular'
  .controller('ProvisioningConfirmCtrl', ($scope, $state, $stateParams, MnoeOrganizations, MnoeProvisioning, MnoeAppInstances, MnoeConfig, ProvisioningHelper, schemaForm) ->

    vm = this

    vm.isLoading = false
    vm.subscription = MnoeProvisioning.getCachedSubscription()
    vm.selectedCurrency = MnoeProvisioning.getSelectedCurrency()
    vm.cartItem = $stateParams.cart == 'true'

    vm.orderTypeText = 'mno_enterprise.templates.dashboard.provisioning.subscriptions.' + $stateParams.editAction.toLowerCase()

    urlParams =
      subscriptionId: $stateParams.subscriptionId
      productId: $stateParams.productId
      editAction: $stateParams.editAction,
      cart: $stateParams.cart

    setCustomSchema = () ->
      vm.model = vm.subscription.custom_data || {}
      schemaForm.jsonref(JSON.parse(vm.subscription.product.custom_schema))
        .then((schema) -> schemaForm.jsonref(schema))
        .then((schema) -> schemaForm.jsonref(schema))
        .then((schema) ->
          vm.schema = schema.json_schema || schema
          vm.form = schema.asf_options || ["*"]
        )

    vm.editOrder = (reload = true) ->
      switch $stateParams.editAction.toLowerCase()
        when 'change', 'new', null
          $state.go('home.provisioning.order', urlParams, {reload: reload})
        else
          $state.go('home.provisioning.additional_details', urlParams, {reload: reload})

    # Happens when the user reload the browser during the provisioning workflow.
    if _.isEmpty(vm.subscription)
      # Redirect the user to the first provisioning screen
      vm.editOrder(true)
    else
      vm.singleBilling = vm.subscription.product.single_billing_enabled
      vm.billedLocally = vm.subscription.product.billed_locally
      vm.subscription.edit_action = $stateParams.editAction
      # Render custom Schema if it exists
      setCustomSchema() if vm.subscription.custom_data && vm.subscription.product.custom_schema

    vm.validate = () ->
      vm.isLoading = true
      vm.subscription.edit_action = $stateParams.editAction
      vm.subscription.cart_entry = true if vm.cartItem
      MnoeProvisioning.saveSubscription(vm.subscription, vm.selectedCurrency).then(
        (response) ->
          if vm.cartItem
            MnoeProvisioning.refreshCartSubscriptions()
            $state.go("home.subscriptions", {subType: 'cart'})
          else
            MnoeProvisioning.setSubscription(response)
            # Reload dock apps
            MnoeAppInstances.getAppInstances().then(
              (response) ->
                $scope.apps = response
            )
            $state.go('home.provisioning.order_summary', {subscriptionId: $stateParams.subscriptionId, editAction: $stateParams.editAction, cart: $stateParams.cart})
      ).finally(-> vm.isLoading = false)

    vm.addToCart = ->
      vm.isLoading = true
      vm.subscription.cart_entry = true
      MnoeProvisioning.saveSubscription(vm.subscription).then(
        (response) ->
          MnoeProvisioning.refreshCartSubscriptions()
          $state.go('home.marketplace')
      ).finally(-> vm.isLoading = false)

    vm.orderEditable = () ->
      # The order is editable if we are changing the plan, or the product has a custom schema.
      switch $stateParams.editAction
        when 'change', 'new'
          true
        else
          if vm.subscription.product?.custom_schema then true else false

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
