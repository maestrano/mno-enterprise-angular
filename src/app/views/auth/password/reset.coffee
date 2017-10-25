angular.module('mnoEnterpriseAngular')
  .controller 'PasswordResetCtrl', ($state, $location, Auth, toastr, MnoErrorsHandler) ->
    'ngInject'

    vm = this
    vm.resetConfirmed = false
    vm.user = {
      $pwdScore: {}
    }

    if !$location.search().reset_password_token
      toastr.error('devise.passwords.no_token', {
        timeOut: 0,
        closeButton: true,
        extendedTimeOut: 0
      })
      $state.go('password_recovery')

    vm.password_reset = ->
      if vm.form.$invalid && !MnoErrorsHandler.onlyServerError(vm.form)
        return
      else if vm.user.password != vm.user.password_confirmation
        toastr.error('Passwords do not match.')
        vm.hasClicked = false
        return

      MnoErrorsHandler.resetErrors(vm.form)

      vm.user.reset_password_token = $location.search().reset_password_token
      Auth.resetPassword(vm.user).then(
        ->
          vm.resetConfirmed = true
          Auth.login(vm.user).then(
            ->
              toastr.success('devise.passwords.updated', {
                timeOut: 10000,
                closeButton: true,
              })
              $state.go('home.impac')
            (error) ->
              toastr.success('devise.passwords.updated_not_active', {
                timeOut: 10000,
                closeButton: true,
              })
          )
      ).catch(
        (error) ->
          if error.status == 422
            toastr.info('devise.passwords.already_reset_error', {
              timeOut: 10000,
              closeButton: true,
            })
            $state.go('login')
          else
            toastr.error('devise.passwords.unspecified_reset_error', {
              timeOut: 10000,
              closeButton: true,
            })
          MnoErrorsHandler.processServerError(error, vm.form)
      ).finally( -> vm.hasClicked = false)

      return true

    return
