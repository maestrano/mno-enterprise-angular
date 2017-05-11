angular.module 'mnoEnterpriseAngular'
  .controller('OnboardingCtrl',(MnoeOrganizations, $state, $q, MnoeCurrentUser, MnoeAppInstances, WizardHandler) ->
    vm = this
    vm.appsSelected = []
    vm.areApps = false
    vm.numberOfAppsConnected = 0
    vm.areAppsConnected = false
    vm.goToDashboard = false
    vm.isWizardShown = true
    vm.areAppsRetrieved = false
    # TODO
    # This is a temporal solution for a conflict on the layout css with the onboarding
    angular.element( document.querySelector( '.myspace' ) ).addClass('onboarding-helper')

    vm.isRecommendationShown = ()->
      vm.appsSelected.length > 4

    vm.canGoToNextStep = ()->
      (vm.appsSelected.length > 0 ) && (vm.appsSelected.length <= 4)

    # This method will delete the organization app instances, and then create new app instances
    vm.purchaseApps = () ->
      vm.areAppsConnected = false
      MnoeAppInstances.getAppInstances().then( ->
        apps = MnoeAppInstances.appInstances
        terminateAppPromises = _.map(apps, (app)-> MnoeAppInstances.terminate(app.id) )
        $q.all(terminateAppPromises).then(->
          purchaseAppPromises = _.map(vm.appsSelected, (selectedApp)-> MnoeOrganizations.purchaseApp(selectedApp))
          $q.all(purchaseAppPromises).then(->
            vm.areAppsConnected = true
          )
        )
      )

    vm.setGoToDashboard = () ->
      vm.goToDashboard = true
      vm.finishedWizard()

    vm.waitForEmail = () ->
      vm.finishedWizard()

    vm.onboardingHelper = () ->
      angular.element( document.querySelector( '.myspace' ) ).removeClass('onboarding-helper')
    
    vm.finishedWizard = () ->
      vm.isWizardShown = false
      if vm.goToDashboard
        WizardHandler.wizard().finish()
        $state.go('home.impac')
        # This will delete the css class added to fix the conflict on the layout css with the onboarding
        setTimeout vm.onboardingHelper, 3000
      else
        WizardHandler.wizard().finish()
        $state.go('onboarding.email-me')

    return
  )
