angular.module 'mnoEnterpriseAngular'
  .controller 'OnboardingStep3Controller', (MnoeOrganizations, MnoeAppInstances) ->
    'ngInject'

    vm = this

    MnoeOrganizations.get().then(
      (response) ->
        vm.organization = response
        MnoeAppInstances.getAppInstances().then(
          (response) ->
            vm.appInstances = response
        )
    )

    return
