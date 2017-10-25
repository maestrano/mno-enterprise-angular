angular.module 'mnoEnterpriseAngular'
  .controller 'LayoutController', ($scope, $rootScope, $stateParams, $state, $q, $timeout, AnalyticsSvc, MnoeCurrentUser, MnoeOrganizations,
  MnoeMarketplace, MnoeAppInstances, MnoeConfig) ->
    'ngInject'

    layout = this

    # Hide the layout with a loader
    $rootScope.isLoggedIn = false

    # Used so parent state loads before children states
    $rootScope.resourcesLoaded = $q.defer()

    # Load the current user
    userPromise = MnoeCurrentUser.get()

    # Load the current organization if defined (url param, cookie or first)
    layout.appInstancesDeferred = $q.defer()
    orgPromise = MnoeOrganizations.getCurrentOrganisation().then(
      (response) ->
        # App instances needs to be run after fetching the organization (At least the first call)
        MnoeAppInstances.getAppInstances().then(
          (appInstances) ->
            if MnoeConfig.isOnboardingWizardEnabled() && _.isEmpty(appInstances)
              $state.go('onboarding.step1')

            layout.appInstancesDeferred.resolve(appInstances)
        )

        response
    )

    $q.all([userPromise, orgPromise, layout.appInstancesDeferred.promise]).then(
      ->
        # Allow child state to load
        $rootScope.resourcesLoaded.resolve()

        # Display the layout
        $rootScope.isLoggedIn = true

        # Pre-load the market place
        MnoeMarketplace.getApps()
    ).catch(
      ->
        # Display the layout
        $rootScope.isLoggedIn = true

        # Display no organisation message
        $rootScope.hasNoOrganisations = true
    )

    $timeout ( -> AnalyticsSvc.init() )

    $rootScope.$on('$stateChangeSuccess', ->
      AnalyticsSvc.update()
    )

    # Impac! is displayed only to admin and super admin
    $scope.$watch(MnoeOrganizations.getSelectedId, (newValue) ->
      MnoeCurrentUser.get().then(
        (response) ->
          # We only check the role for those states
          if $state.is('home.impac') || $state.is('home.apps')
            selectedOrg = _.find(response.organizations, {id: newValue})
            if MnoeOrganizations.role.atLeastAdmin(selectedOrg.current_user_role)
              $state.go('home.impac')
            else
              $state.go('home.apps')
      ) if newValue?
    )



    return
