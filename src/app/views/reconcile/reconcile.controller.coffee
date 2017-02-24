angular.module 'mnoEnterpriseAngular'
  .controller 'ReconcileController', (DOCK_CONFIG) ->
    'ngInject'

    vm = this
    vm.isDockEnabled = DOCK_CONFIG.enabled

    return
