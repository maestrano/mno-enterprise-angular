angular.module 'mnoEnterpriseAngular'
  .controller('ProvisioningConfirmCtrl', ($scope, $state, $stateParams, MnoeOrganizations, MnoeProvisioning, MnoeAppInstances, MnoeConfig, EDIT_ACTIONS) ->

    vm = this

    vm.isLoading = false
    vm.subscription = MnoeProvisioning.getSubscription()
    vm.singleBilling = vm.subscription.product.single_billing_enabled
    vm.billedLocally = vm.subscription.product.billed_locally

    # Happens when the user reload the browser during the provisioning workflow.
    if _.isEmpty(vm.subscription)
      # Redirect the user to the first provisioning screen
      $state.go('home.provisioning.order', {id: $stateParams.id, nid: $stateParams.nid}, {reload: true})

    vm.editOrder = () ->
      $state.go('home.provisioning.order', {id: $stateParams.id, nid: $stateParams.nid})


    vm.validate = () ->
      vm.isLoading = true
      MnoeProvisioning.saveSubscription(vm.subscription).then(
        (response) ->
          MnoeProvisioning.setSubscription(response)
          # Reload dock apps
          MnoeAppInstances.getAppInstances().then(
            (response) ->
              $scope.apps = response
          )
          $state.go('home.provisioning.order_summary', {id: $stateParams.id, nid: $stateParams.nid})
      ).finally(-> vm.isLoading = false)

    vm.editOrder = () ->
      params =
        nid: $stateParams.nid,
        orgId: $stateParams.orgId
        id: $stateParams.id,
        editAction: $stateParams.editAction

      switch $stateParams.editAction
        when 'CHANGE', 'NEW', null
          $state.go('home.provisioning.order', params)
        else
          $state.go('home.provisioning.additional_details', params)

    if _.isEmpty(vm.subscription)
      vm.editOrder()

    vm.subscription.edit_action = $stateParams.editAction

    vm.orderTypeText = (editAction) ->
      EDIT_ACTIONS[editAction]

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
