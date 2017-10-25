angular.module 'mnoEnterpriseAngular'
  .controller('AuthLoungeCtrl',
    ($state, $stateParams, MnoeAuthSvc, toastr, MnoErrorsHandler) ->
      vm = @
      vm.user = {}
      vm.user.email = $stateParams.email
      resentConfirmation = 0

      vm.resendConfirmation = ->
        MnoeAuthSvc.all('/users').all('/confirmation').patch({user: vm.user}).finally(
          ->
            resentConfirmation += 1
            toastr.info("If your email address exists in our database and is unconfirmed, you will receive an email with instructions in a few minutes.(#{resentConfirmation})")
            vm.hasClicked = false
        )

      return
  )
