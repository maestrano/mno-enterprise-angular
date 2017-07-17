angular.module 'mnoEnterpriseAngular'
  .controller 'OnboardingController', (MnoeCurrentUser) ->
    'ngInject'

    onboarding = this
    onboarding.menu = {}
    onboarding.menu.isClosed = true

    onboarding.menu.toggle = () ->
      onboarding.menu.isClosed = !onboarding.menu.isClosed

    MnoeCurrentUser.get().then(
      (response) ->
        onboarding.user = response
    )

    return
