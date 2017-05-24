angular.module 'mnoEnterpriseAngular'
  .controller 'OnboardingStep3Controller', (MnoeOrganizations, MnoeAppInstances) ->
    'ngInject'

    vm = this

    vm.isFetchingAppInstances = true

    MnoeAppInstances.getAppInstances().then(
      (response) ->
        vm.appInstances = response
        vm.isFetchingAppInstances = false
    )

    return
