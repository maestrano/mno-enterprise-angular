angular.module 'mnoEnterpriseAngular'
  .controller('SubscriptionInfoController', ($uibModalInstance) ->
    vm = this

    vm.onCancel = () ->
      $uibModalInstance.dismiss('cancel')

    return
  )
