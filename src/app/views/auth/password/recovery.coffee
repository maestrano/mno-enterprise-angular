angular.module('mnoEnterpriseAngular')
  .controller 'PasswordRecoveryCtrl', ($state, Auth, toastr, MnoErrorsHandler) ->
    'ngInject'

    vm = this
    vm.request_sent = false

    vm.password_recovery = ->
      if vm.form.$invalid && !MnoErrorsHandler.onlyServerError(vm.form)
        return

      MnoErrorsHandler.resetErrors(vm.form)

      Auth.sendResetPasswordInstructions(vm.user).then(
        ->
          toastr.info('devise.passwords.send_paranoid_instructions', {
            timeOut: 0,
            closeButton: true,
            extendedTimeOut: 0
          })
          $state.go('login')
          vm.request_sent = true
          (error) ->
            MnoErrorsHandler.processServerError(error, vm.form)
        ).finally( -> vm.hasClicked = false)

      return true

    return
