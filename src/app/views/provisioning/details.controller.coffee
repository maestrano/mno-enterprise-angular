angular.module 'mnoEnterpriseAngular'
  .controller('ProvisioningDetailsCtrl', ($state, MnoeMarketplace, MnoeProvisioning, schemaForm, EDIT_ACTIONS) ->

    vm = this

    vm.form = [ "*" ]

    vm.subscription = MnoeProvisioning.getSubscription()
    vm.isEditMode = !_.isEmpty(vm.subscription.custom_data)
    vm.availableEditActions = vm.subscription.available_edit_actions
    # Set default edit action
    vm.activeTab = vm.availableEditActions[0]

    # The schema is contained in field vm.product.custom_schema
    #
    # jsonref is used to resolve $ref references
    # jsonref is not cyclic at this stage hence the need to make a
    # reasonable number of passes (2 below + 1 in the sf-schema directive)
    # to resolve cyclic references
    #

    vm.getSubscription = () ->
      vm.isLoading = true

      # Must pass in the active tab, as this dictates which json-schema we will receive.
      MnoeMarketplace.getProduct(vm.subscription.product.id, { editAction: vm.activeTab })
        .then((response) -> JSON.parse(response.custom_schema))
        .then((schema) -> schemaForm.jsonref(schema))
        .then((schema) -> schemaForm.jsonref(schema))
        .then((schema) ->
          vm.schema = schema
          vm.isLoading = false
          )

    vm.submit = (form) ->
      return if form.$invalid
      vm.subscription.editAction = vm.activeTab
      MnoeProvisioning.setSubscription(vm.subscription)
      $state.go('home.provisioning.confirm')

    vm.editButtonText = (editAction) ->
      if editAction == 'SUSPEND' && vm.subscription.status == 'suspended'
        EDIT_ACTIONS['REACTIVATE']
      else
        EDIT_ACTIONS[editAction]

    vm.getSubscription()
    return
  )
