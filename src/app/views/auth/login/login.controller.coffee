angular.module 'mnoEnterpriseAngular'
  .controller('AuthLoginCtrl',
    (Auth, toastr, $state, DEVISE_CONFIG) ->
      vm = @

      vm.login = ->
        Auth.login(vm.user).then(
          ->
            toastr.success('You have successfully logged in!')
            $state.go('home.impac')
          (error) ->
            toastr.error(error.data.error)
        ).finally(-> vm.hasClicked = false)

      return
  )
