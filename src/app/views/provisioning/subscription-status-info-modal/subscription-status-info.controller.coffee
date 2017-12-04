angular.module 'mnoEnterpriseAngular'
  .controller('SubscriptionInfoController', ($filter, $stateParams, $log, $uibModalInstance) ->
    vm = this

    vm.onCancel = () ->
      $uibModalInstance.dismiss('cancel')

    return
  )
