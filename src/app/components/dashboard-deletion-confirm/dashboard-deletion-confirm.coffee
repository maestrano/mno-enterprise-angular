angular.module 'mnoEnterpriseAngular'
  .component('dashboardDeletionConfirm', {
    templateUrl: 'app/components/dashboard-deletion-confirm/dashboard-deletion-confirm.html',
    bindings: {
      resolve: '<'
      close: '&'
      dismiss: '&'
    }
    controller: ($log, $state, toastr) ->
      ctrl = this
      ctrl.password = ""
      ctrl.delReasons = ""
      ctrl.isLoading = false

      ctrl.cancel = () ->
        ctrl.dismiss({$value: "cancel"})

      ctrl.ok = () ->
        ctrl.isLoading = true

        # Launch Cb
        ctrl.resolve.actionCb(ctrl.delReasons, ctrl.password).then(
          (response) ->
            toastr.success('Organization successfully frozen')
            # Reload the state to block access to Impac!, marketplace, ...
            $state.reload()
            ctrl.close(response)
          (errors) ->
            $log.error(errors)
            toastr.error(errors.statusText, "Error")
        ).finally(-> ctrl.isLoading = false)
      return
    })
