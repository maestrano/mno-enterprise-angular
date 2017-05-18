angular.module 'mnoEnterpriseAngular'
  .controller 'OnboardingStep1Controller', (MnoeCurrentUser) ->
    'ngInject'

    vm = this

    MnoeCurrentUser.get().then(
      (response) ->
        vm.user = response
    )

    return
