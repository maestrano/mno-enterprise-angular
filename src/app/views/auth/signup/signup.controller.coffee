angular.module 'mnoEnterpriseAngular'
  .controller('AuthSignUpCtrl',
    ($state, Auth, toastr, MnoErrorsHandler) ->
      vm = @

      vm.errorHandler = MnoErrorsHandler

      vm.checkServerErrors = ->
        MnoErrorsHandler.resetErrors(vm.form) if vm.form['email'].$error.server

      vm.signup = ->
        # Is form valid and if there is errors that are not server type
        if vm.form.$invalid && !MnoErrorsHandler.onlyServerError(vm.form)
          return

        # Reset last error
        MnoErrorsHandler.resetErrors(vm.form)

        Auth.register(vm.user).then(
          (response) ->
            toastr.success('Signup successful')
            Auth._currentUser = null
            $state.go('confirmation_lounge', { email: vm.user.email })
          (error) ->
            MnoErrorsHandler.processServerError(error, vm.form)
        ).finally(-> vm.hasClicked = false)

      return
  )
