angular.module 'mnoEnterpriseAngular'
  .controller('ProvisioningDetailsCtrl', ($scope, $state, MnoeMarketplace, MnoeProvisioning, schemaForm, $stateParams) ->

    vm = this

    vm.form = [ "*" ]

    vm.subscription = MnoeProvisioning.getSubscription()

    # Happens when the user reload the browser during the provisioning
    if _.isEmpty(vm.subscription)
      # Redirect the user to the first provisioning screen
      $state.go('home.provisioning.order', {id: $stateParams.id, nid: $stateParams.nid})

    vm.isEditMode = !_.isEmpty(vm.subscription.custom_data)

    # The schema is contained in field vm.product.custom_schema
    #
    # jsonref is used to resolve $ref references
    # jsonref is not cyclic at this stage hence the need to make a
    # reasonable number of passes (2 below + 1 in the sf-schema directive)
    # to resolve cyclic references
    #
    MnoeMarketplace.findProduct(id: vm.subscription.product.id)
      .then((response) ->JSON.parse(response.custom_schema))
      .then((schema) -> schemaForm.jsonref(schema))
      .then((schema) -> schemaForm.jsonref(schema))
      .then((schema) -> vm.schema = schema)

    vm.submit = (form) ->
      return if form.$invalid
      MnoeProvisioning.setSubscription(vm.subscription)
      $state.go('home.provisioning.confirm', {id: $stateParams.id, nid: $stateParams.nid})

    # Delete the cached subscription when we are leaving the subscription workflow.
    $scope.$on('$stateChangeStart', (event, toState) ->
      switch toState.name
        when "home.provisioning.order", "home.provisioning.order_summary", "home.provisioning.confirm"
          null
        else
          MnoeProvisioning.setSubscription({})
    )

    return
  )
