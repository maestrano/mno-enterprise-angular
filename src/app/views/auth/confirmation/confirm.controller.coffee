angular.module 'mnoEnterpriseAngular'
  .controller('AuthConfirmCtrl',
    ($state, $stateParams, MnoeAuthSvc, toastr, MnoErrorsHandler) ->
      vm = @
      vm.user = { phone_country_code: "US", confirmation_token: $stateParams.confirmation_token}
      vm.$pwdScore = {}
      vm.phoneRequired = "required"

      MnoeAuthSvc.one("/users/confirmation").get({confirmation_token: vm.user.confirmation_token}).then(
        (response) ->
          if response.attributes.new_email_confirmed
            toastr.success('Email confirmed successfully')
            $state.go('home.impac')
          else if response.attributes.confirmed_at
            toastr.info('User already confirmed')
            $state.go('login')
          else if response.attributes.no_phone_required
            vm.phoneRequired = ''
        (error) ->
          toastr.error("Confirmation token is invalid")
          $state.go('login')
      )

      vm.confirmUser = ->
        delete vm.user.$pwdScore
        MnoeAuthSvc.one("/users/confirmation/finalize").patch({user: vm.user}).then(
          ->
            toastr.success('User confirmed successfully')
            $state.go('home.impac')
          (error) ->
            toastr.error('Confirmation unsuccessful, please try again')
            vm.hasClicked = false
        )

      return
  )
