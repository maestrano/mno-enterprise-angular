angular.module 'mnoEnterpriseAngular'
  .controller 'OnboardingController', (MnoeCurrentUser) ->
    'ngInject'

    onboarding = this

    MnoeCurrentUser.get().then(
      (response) ->
        onboarding.user = response
    )

    return
