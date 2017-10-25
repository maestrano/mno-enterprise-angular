angular.module 'mnoEnterpriseAngular'
  .controller('AuthConfirmRecoveryCtrl',
    ($state, $stateParams, MnoeAuthSvc, toastr, MnoErrorsHandler) ->
      vm = @
      vm.user = {}

      vm.resendConfirmation = ->
        MnoeAuthSvc.all('/users/confirmation').post({user: vm.user}).then(
          ->
            toastr.info('If your email address exists in our database and is unconfirmed, you will receive an email with instructions in a few minutes.')
            $state.go('login')
          ->
            toastr.error('Your request was unsuccessful, please try again or contact your platform administrator.')
        )
      return
  )
