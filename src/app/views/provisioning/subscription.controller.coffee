angular.module 'mnoEnterpriseAngular'
  .controller('ProvisioningSubscriptionCtrl', ($stateParams, $filter, $uibModal, MnoeProvisioning, MnoeMarketplace, ProvisioningHelper) ->

    vm = this

    vm.isLoading = true
    # We must use model schemaForm's sf-model, as #json_schema_opts are namespaced under model
    vm.model = {}
    # Methods under the vm.model are used for calculated fields under #json_schema_opts.

    # Used to calculate the end date for forms with a contractEndDate.
    vm.model.calculateEndDate = (startDate, contractLength) ->
      return null unless startDate && contractLength
      moment(startDate)
      .add(contractLength.split('Months')[0], 'M')
      .format('YYYY-MM-DD')

    MnoeProvisioning.fetchSubscription($stateParams.id).then(
      (response) ->
        vm.subscription = response
        unless _.isEmpty(vm.subscription.custom_data)
          vm.model = vm.subscription.custom_data

          MnoeMarketplace.fetchCustomSchema(vm.subscription.product_id).then((response) ->
            # Some products have custom schemas, whereas others do not.
            resp = JSON.parse(response)
            vm.schema = if resp?.json_schema then resp.json_schema else resp
            vm.form = if resp?.asf_options then resp.asf_options else ["*"]
          )
    ).finally(-> vm.isLoading = false)

    MnoeProvisioning.getSubscriptionEvents($stateParams.id).then(
      (response) ->
        vm.subscriptionEvents = response
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
