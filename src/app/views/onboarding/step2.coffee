angular.module 'mnoEnterpriseAngular'
  .controller 'OnboardingStep2Controller', ($q, $uibModal, MnoeMarketplace) ->
    'ngInject'

    vm = this

    vm.isLoading = true
    vm.selectedApps = []

    # Select or deselect an app
    vm.toggleApp = (app) ->
      app.checked = !app.checked
      if app.checked
        vm.selectedApps.push(app)
      else
        _.remove(vm.selectedApps, app)

    # ====================================
    # Info modal
    # ====================================
    vm.openInfoModal = (app) ->
      console.log("### DEBUG openInfoModal", app)
      $uibModal.open(
        templateUrl: 'app/views/onboarding/modals/app-infos.html'
        controller: 'MnoAppInfosCtrl'
        controllerAs: 'vm',
        size: 'lg'
        resolve:
          app: app
      )

    MnoeMarketplace.getApps().then(
      (response) ->
        vm.marketplace = response.plain()
    ).finally(-> vm.isLoading = false)

    return
