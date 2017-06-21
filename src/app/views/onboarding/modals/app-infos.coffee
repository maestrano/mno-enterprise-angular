angular.module 'mnoEnterpriseAngular'
  .controller('MnoAppInfosCtrl', ($uibModalInstance, app) ->
    vm = this
    vm.app = app

    vm.close = ->
      $uibModalInstance.close()

    return
)
