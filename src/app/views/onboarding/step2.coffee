angular.module 'mnoEnterpriseAngular'
  .controller 'OnboardingStep2Controller', (MnoeCurrentUser) ->
    'ngInject'

    vm = this

    MnoeCurrentUser.get().then(
      (response) ->
        console.log response
        vm.user = response
    )

    return
