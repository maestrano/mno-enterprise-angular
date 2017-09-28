angular.module 'mnoEnterpriseAngular'
  .controller('ProvisioningSubscriptionsCtrl', ($q, $state, $stateParams, toastr, MnoeOrganizations, MnoeProvisioning, MnoeConfig, MnoConfirm) ->

    vm = this
    vm.isLoading = true
    
    vm.goToSubscription = (subscription) ->
      $state.go('home.subscription', { subscription: subscription })

    vm.cancelSubscription = (subscription, i) ->
      modalOptions =
        headerText: 'mno_enterprise.templates.dashboard.provisioning.subscriptions.cancel_modal.title'
        bodyText: 'mno_enterprise.templates.dashboard.provisioning.subscriptions.cancel_modal.body'
        closeButtonText: 'mno_enterprise.templates.dashboard.provisioning.subscriptions.cancel_modal.no'
        actionButtonText: 'mno_enterprise.templates.dashboard.provisioning.subscriptions.cancel_modal.yes'
        actionCb: -> MnoeProvisioning.cancelSubscription(subscription).then(
          (response) ->
            angular.copy(response.subscription, vm.subscriptions[i])
          ->
            toastr.error('mno_enterprise.templates.dashboard.provisioning.subscriptions.cancel_error')
        )
        type: 'danger'

      MnoConfirm.showModal(modalOptions)

    orgPromise = MnoeOrganizations.get()
    subPromise = MnoeProvisioning.getSubscriptions()

    $q.all({organization: orgPromise, subscriptions: subPromise}).then(
      (response) ->
        vm.orgCurrency = response.organization.billing?.current?.options?.iso_code || MnoeConfig.marketplaceCurrency()

        # If a subscription doesn't contains a pricing for the org currency, a warning message is displayed
        vm.displayCurrencyWarning = not _.every(response.subscriptions, (subscription) ->
          currencies = _.map(subscription?.product_pricing?.prices, 'currency')
          _.includes(currencies, vm.orgCurrency)
        )
        vm.subscriptions = response.subscriptions
    ).finally(-> vm.isLoading = false)

    return
  )
