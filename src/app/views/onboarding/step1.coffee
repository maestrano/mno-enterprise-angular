angular.module 'mnoEnterpriseAngular'
  .controller 'OnboardingStep1Controller', (MnoeCurrentUser) ->
    'ngInject'

    vm = this

    vm.isLoading = true

    MnoeCurrentUser.get().then(
      (response) ->
        vm.user = response
    ).finally(-> vm.isLoading = false)

    return
