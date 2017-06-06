angular.module 'mnoEnterpriseAngular'
  .controller 'OnboardingStep3Controller', (MnoeOrganizations, MnoeAppInstances) ->
    'ngInject'

    vm = this

    vm.isFetchingAppInstances = true

    MnoeAppInstances.getAppInstances().then(
      (response) ->
        vm.appInstances = angular.copy(response.app_instances)
        vm.nbAppsToConnect = _.filter(vm.appInstances, (ai) -> MnoeAppInstances.installStatus(ai) == "INSTALLED_CONNECT").length
    ).finally(-> vm.isFetchingAppInstances = false)

    return
