angular.module 'mnoEnterpriseAngular'
  .controller('AuthConfirmCtrl',
    ($state, $stateParams, MnoeAuthSvc, toastr, MnoErrorsHandler) ->
      vm = @
      vm.user = { phone_country_code: "US", confirmation_token: $stateParams.confirmation_token}
      vm.$pwdScore = {}

      MnoeAuthSvc.one("/users/confirmation").get({confirmation_token: vm.user.confirmation_token}).then(
        (response) ->
          debugger
          if response.attributes.confirmed_at
            toastr.info('User already confirmed')
            $state.go('login')
        (error) ->
          toastr.error("Confirmation token is invalid")
          $state.go('login')
      )

      vm.confirmUser = ->
        delete vm.user.$pwdScore
        MnoeAuthSvc.one("/users/confirmation/finalize").patch({user: vm.user}).then(
          ->
            toastr.successs('User confirmed successfully')
            $state.go('impac')
          (error) ->
            toastr.error('Confirmation unsuccessful, please try again')
            vm.hasClicked = false
        )

      return
  )
