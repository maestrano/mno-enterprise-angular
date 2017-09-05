angular.module 'mnoEnterpriseAngular'
  .controller('DashboardMarketplaceCtrl', (MnoeConfig) ->
    vm = this

    vm.areLocalProductsEnabled = MnoeConfig.areLocalProductsEnabled()

    return
  )
