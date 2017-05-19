angular.module 'mnoEnterpriseAngular'
  .controller 'OnboardingStep2Controller', ($q, $state, $uibModal, MnoeMarketplace, MnoeOrganizations, MnoeAppInstances) ->
    'ngInject'

    vm = this

    MAX_APPS_ONBOARDING = 4

    vm.searchTerm = ''
    vm.isLoading = true

    vm.selectedApps = []

    # Select or deselect an app
    vm.toggleApp = (app) ->
      # User cannot add more apps
      return if vm.maxAppsSelected && !app.checked
      app.checked = !app.checked
      if app.checked
        vm.selectedApps.push(app)
      else
        _.remove(vm.selectedApps, app)
      vm.maxAppsSelected = (vm.selectedApps.length == MAX_APPS_ONBOARDING)

    vm.connectApps = () ->
      vm.isConnectingApps = true
      # List of checked apps
      apps = _.filter(vm.marketplace.apps, {checked: true})
      promises = _.map(apps, (app) ->
        MnoeOrganizations.purchaseApp(app)
      )
      $q.all(promises).finally(
        ->
          MnoeAppInstances.refreshAppInstances().then(
            ->
              vm.isConnectingApps = false
              $state.go('onboarding.step3')
          )
      )

    # ====================================
    # Info modal
    # ====================================
    vm.openInfoModal = (app) ->
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
