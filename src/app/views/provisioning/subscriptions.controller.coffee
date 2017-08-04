angular.module 'mnoEnterpriseAngular'
  .controller('ProvisioningSubscriptionsCtrl', ($stateParams, toastr, MnoeOrganizations, MnoeProvisioning, MnoeConfig, MnoConfirm) ->

    vm = this
    vm.isLoading = true

    vm.cancelSubscription = (subscription, key) ->
      modalOptions =
        headerText: 'mno_enterprise.templates.dashboard.provisioning.subscriptions.cancel_modal.title'
        bodyText: 'mno_enterprise.templates.dashboard.provisioning.subscriptions.cancel_modal.body'
        closeButtonText: 'mno_enterprise.templates.dashboard.provisioning.subscriptions.cancel_modal.no'
        actionButtonText: 'mno_enterprise.templates.dashboard.provisioning.subscriptions.cancel_modal.yes'
        actionCb: -> MnoeProvisioning.cancelSubscription(subscription).then(
          ->
            vm.subscriptions.splice(key, 1)
          ->
            toastr.error('mno_enterprise.templates.dashboard.provisioning.subscriptions.cancel_error')
        )
        type: 'danger'

      MnoConfirm.showModal(modalOptions)

    MnoeOrganizations.get().then(
      (response) ->
        vm.orgCurrency = response.billing?.current?.options?.iso_code || MnoeConfig.marketplaceCurrency()
    )

    MnoeProvisioning.getSubscriptions().then(
      (response) ->
        vm.subscriptions = response
    ).finally(-> vm.isLoading = false)

    return
  )
