angular.module 'mnoEnterpriseAngular'
  .controller('ProvisioningConfirmCtrl', ($scope, $state, MnoeOrganizations, MnoeProvisioning, MnoeAppInstances, MnoeConfig, EDIT_ACTIONS) ->

    vm = this

    vm.isLoading = false
    vm.subscription = MnoeProvisioning.getSubscription()

    vm.validateButtonText = ->
      EDIT_ACTIONS[vm.subscription.editAction] || 'Validate'

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
          $state.go('home.provisioning.order_summary')
      ).finally(-> vm.isLoading = false)

    MnoeOrganizations.get().then(
      (response) ->
        vm.orgCurrency = response.organization?.billing_currency || MnoeConfig.marketplaceCurrency()
    )

    return
  )
