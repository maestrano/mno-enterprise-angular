angular.module 'mnoEnterpriseAngular'
  .controller('ProvisioningDetailsCtrl', ($state, MnoeProvisioning) ->

    vm = this

    vm.form = [ "*" ]

    vm.model = MnoeProvisioning.getCustomData()

    # The schema is contained in field vm.product.custom_schema
    vm.product = MnoeProvisioning.getCurrentProduct()
    vm.isEditMode = !_.isEmpty(vm.model)
    console.log("### DEBUG custom_schema", vm.product.custom_schema)
    vm.schema = JSON.parse(vm.product.custom_schema)
    console.log("### DEBUG vm.schema", vm.schema)

    vm.submit = (form, model) ->
      return if form.$invalid
      console.log("### DEBUG model", model)
      console.log("### DEBUG form", form)
      MnoeProvisioning.setCustomData(model)
      $state.go('home.provisioning.confirm')

    return
  )
