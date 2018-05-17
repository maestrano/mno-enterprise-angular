angular.module 'mnoEnterpriseAngular'
  .controller('ProvisioningSubscriptionsCtrl', ($q, $state, $stateParams, toastr, MnoeOrganizations, MnoeProvisioning, MnoeConfig, MnoConfirm, PRICING_TYPES) ->

    vm = this
    vm.isLoading = true
    vm.cartSubscriptions = $stateParams.subType == 'cart'

    vm.goToSubscription = (subscription) ->
      $state.go('home.subscription', { id: subscription.id, cart: vm.cartSubscriptions })

    vm.cancelSubscription = (subscription, i) ->
      if vm.cartSubscriptions
        subscription.cart_entry = true
        headerText = 'mno_enterprise.templates.dashboard.provisioning.subscriptions.cart.cancel_modal.title'
        bodyText = 'mno_enterprise.templates.dashboard.provisioning.subscriptions.cart.cancel_modal.body'
      else
        headerText = 'mno_enterprise.templates.dashboard.provisioning.subscriptions.cancel_modal.title'
        bodyText = 'mno_enterprise.templates.dashboard.provisioning.subscriptions.cancel_modal.body'

      # TODO: When cart item is removed, we want to update the cart subscriptions
      #       and not show cancelled subscription in response.

      modalOptions =
        headerText: headerText
        bodyText: bodyText
        closeButtonText: 'mno_enterprise.templates.dashboard.provisioning.subscriptions.cancel_modal.no'
        actionButtonText: 'mno_enterprise.templates.dashboard.provisioning.subscriptions.cancel_modal.yes'
        actionCb: -> MnoeProvisioning.cancelSubscription(subscription).then(
          (response) ->
            if vm.cartSubscriptions
              vm.subscriptions = _.reject(vm.subscriptions, (sub) -> sub.id == subscription.id)
            else
              angular.copy(response.subscription, vm.subscriptions[i])
          ->
            toastr.error('mno_enterprise.templates.dashboard.provisioning.subscriptions.cancel_error')
        )
        type: 'danger'

      MnoConfirm.showModal(modalOptions)

    # NOte: we might not need this one anymore based on rework
    vm.modifySubscription = (subscription, i) ->
      if vm.cartSubscriptions
        $state.go("home.provisioning.order", {id: subscription.id, cart: true})
      else
        $state.go("home.provisioning.order", {id: subscription.id})

    vm.subscriptionsPromise = ->
      if vm.cartSubscriptions
        params = { where: {subscription_status_in: 'staged' } }
        MnoeProvisioning.getSubscriptions(params)
      else
        params = { where: {subscription_status_in: 'non_staged' } }
        MnoeProvisioning.getSubscriptions(params)

    vm.deleteCart = ->
      MnoeProvisioning.deleteCartSubscriptions().then(
        (response) ->
          MnoeProvisioning.emptySubscriptions()
          toastr.info('mno_enterprise.templates.dashboard.provisioning.subscriptions.cart.delete_cart.toastr')
          $state.go("home.marketplace")
      )

    vm.submitCart = ->
      MnoeProvisioning.submitCartSubscriptions().then(
        (response) ->
          # Reload dock apps
          MnoeProvisioning.refreshSubscriptions()

          toastr.success('mno_enterprise.templates.dashboard.provisioning.subscriptions.cart.submit_cart.toastr')
          $state.go("home.subscriptions", {subType: 'active'})
      )

    orgPromise = MnoeOrganizations.get()
    subPromise = vm.subscriptionsPromise()

    $q.all({organization: orgPromise, subscriptions: subPromise}).then(
      (response) ->
        vm.subscriptions = response.subscriptions
        if vm.cartSubscriptions && vm.subscriptions.length < 1
          toastr.info('mno_enterprise.templates.dashboard.provisioning.subscriptions.cart.empty')
          $state.go('home.marketplace')
          return

        vm.orgCurrency = response.organization.organization?.billing_currency || MnoeConfig.marketplaceCurrency()

        # If a subscription doesn't contains a pricing for the org currency, a warning message is displayed
        vm.displayCurrencyWarning = not _.every(response.subscriptions, (subscription) ->
          currencies = _.map(subscription?.product_pricing?.prices, 'currency')
          _.includes(currencies, vm.orgCurrency) || (subscription?.product_pricing?.pricing_type in PRICING_TYPES['unpriced'])
        )
    ).finally(-> vm.isLoading = false)

    vm.displayInfoTooltip = (subscription) ->
      return subscription.status == 'aborted'

    vm.showEditAction = (subscription, editAction) ->
      return false unless subscription.available_actions
      editAction in subscription.available_actions

    vm.editSubscription = (subscription, editAction) ->
      MnoeProvisioning.setSubscription({})
      params = {subscriptionId: subscription.id, editAction: editAction}
      switch editAction.toLowerCase( )
        when 'change'
          $state.go('home.provisioning.order', params)
        else
          $state.go('home.provisioning.additional_details', params)

    return
  )
