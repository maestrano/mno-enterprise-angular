angular.module 'mnoEnterpriseAngular'
  .controller('ProvisioningDetailsCtrl', (MnoeProvisioning) ->

    vm = this

    vm.form = [ "*" ];

    vm.submit = (form) ->
      console.log("### DEBUG vm.model", vm.model)
      console.log("### DEBUG form", form)

    MnoeProvisioning.fetchJsonSchema().then(
      (response) ->
        console.log("### DEBUG JSON Schema", response)
        vm.schema = response
    )

    return
  )
