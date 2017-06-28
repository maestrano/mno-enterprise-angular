angular.module 'mnoEnterpriseAngular'
  .controller('ProvisioningOrderCtrl', ($stateParams, MnoeMarketplace) ->

    vm = this

    MnoeMarketplace.getApps().then(
      ->
        vm.app = MnoeMarketplace.findApp($stateParams.nid)
    )

    return
  )
