angular.module 'mnoEnterpriseAngular'
  .controller('ProvisioningSubscriptionCtrl', ($stateParams, $filter, $uibModal, MnoeProvisioning, MnoeMarketplace) ->

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

    MnoeProvisioning.getSubscriptionEvents($stateParams.id).then(
      (response) ->
        vm.subscriptionEvents = response.subscription_events
    )

    # Configure user friendly json tree
    vm.rootName = $filter('translate')('mno_enterprise.templates.dashboard.provisioning.subscription.provisioning_data_root_name')
    vm.jsonTreeSettings = {
      dateFormat: 'yyyy-MM-dd HH:mm:ss'
    }

    vm.displayInfoTooltip = ->
      return vm.subscription.status == 'aborted'

    vm.displayStatusInfo = ->
      modalInstance = $uibModal.open(
        templateUrl: 'app/views/provisioning/subscription-status-info-modal/subscription-status-info.html'
        controller: 'SubscriptionInfoController'
        controllerAs: 'vm'
      )

    return
  )
