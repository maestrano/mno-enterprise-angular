angular.module 'mnoEnterpriseAngular'
  .controller('ProvisioningSubscriptionCtrl', ($stateParams, $filter, $uibModal, MnoeProvisioning, MnoeMarketplace, ProvisioningHelper) ->

    vm = this

    vm.isLoading = true

    # We must use model schemaForm's sf-model, as #json_schema_opts are namespaced under model
    vm.model = {}
    # Methods under the vm.model are used for calculated fields under #json_schema_opts.

    # Used to calculate the end date for forms with a contractEndDate.
    vm.model.calculateEndDate = (startDate, contractLength) ->
      return nil unless startDate && contractLength
      moment(startDate)
      .add(contractLength.split('Months')[0], 'M')
      .format('YYYY-MM-DD')

    MnoeProvisioning.fetchSubscription($stateParams.id).then(
      (response) ->
        vm.subscription = response
        if vm.subscription.custom_data?
          vm.model = vm.subscription.custom_data
          MnoeMarketplace.findProduct(id: vm.subscription.product_id).then(
            (response) ->
              vm.schema = JSON.parse(response.custom_schema)
              # Schemas with optional asf_options will be namespaced under #json_schema
              vm.form = if vm.schema.asf_options then vm.schema.asf_options else ["*"]
              vm.schema = vm.schema.json_schema if vm.schema.json_schema
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

    # Return true if the plan has a dollar value
    vm.pricedPlan = ProvisioningHelper.pricedPlan

    return
  )
