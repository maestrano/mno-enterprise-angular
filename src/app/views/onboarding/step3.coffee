angular.module 'mnoEnterpriseAngular'
  .controller 'OnboardingStep3Controller', (MnoeOrganizations, MnoeAppInstances) ->
    'ngInject'

    vm = this

    MnoeAppInstances.getAppInstances().then(
      (response) ->
        vm.appInstances = response
    )

    return
