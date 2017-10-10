angular.module 'mnoEnterpriseAngular'
  .component('dashboardDeletionConfirm', {
    templateUrl: 'app/components/dashboard-deletion-confirm/dashboard-deletion-confirm.html',
    bindings: {
      resolve: '<'
      close: '&'
      dismiss: '&'
    }
    controllerAs: "delConfirmCtrl"
    controller: ($log, toastr) ->
      vm = this
      vm.password = ""
      vm.delReasons = ""
      vm.isLoading = false

      vm.cancel = () ->
        vm.dismiss({$value: "cancel"})

      vm.ok = () ->
        vm.isLoading = true

        # Launch Cb
        vm.resolve.actionCb(vm.delReasons, vm.password).then(
          (response) ->
            toastr.success('Organization successfully frozen')
            vm.close(response)
          (errors) ->
            $log.error(errors)
            toastr.error(errors.statusText, "Error")
        ).finally(-> vm.isLoading = false)
      return
    })
