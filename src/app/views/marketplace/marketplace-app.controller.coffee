#============================================
#
#============================================
angular.module 'mnoEnterpriseAngular'
  .controller('DashboardMarketplaceAppCtrl',
    ($q, $scope, $stateParams, $state, $sce, $window, MnoeMarketplace, $uibModal, MnoeOrganizations, MnoeCurrentUser, MnoeAppInstances, PRICING_CONFIG) ->

      vm = this

      #====================================
      # Pre-Initialization
      #====================================
      vm.isLoading = true
      vm.app = {}
      # The already installed app instance of the app, if any
      vm.appInstance = null
      # An already installed app, conflicting with the app because it contains a common subcategory
      # that is not multi instantiable, if any
      vm.conflictingApp = null
      #====================================
      # Scope Management
      #====================================
      vm.initialize = (app, appInstance, conflictingApp) ->
        angular.copy(app, vm.app)
        vm.appInstance = appInstance
        vm.conflictingApp = conflictingApp
        vm.app.description = $sce.trustAsHtml(app.description)
        vm.isLoading = false
        plans = vm.app.pricing_plans
        currency = (PRICING_CONFIG && PRICING_CONFIG.currency) || 'AUD'
        vm.pricing_plans = plans[currency] || plans.AUD || plans.default

        # Get the current organization id
        MnoeOrganizations.getCurrentId().then(
          (orgId) ->
            vm.current_organization = {
              id: orgId
            }

            #  Get the list of organizations
            MnoeCurrentUser.get().then(
              (response) ->
                vm.organizations = {}  # Hash of organizations id -> {obj}
                vm.authorized_organizations = {}

                vm.filterAuthorizedOrga(response.organizations)
                vm.hasAuthorizedOrganizations = !_.isEmpty(vm.authorized_organizations)
            )
        )

      # Filter the authorized organizations for this user
      vm.filterAuthorizedOrga = (organizations) ->
        organizations.map(
          (orga) ->
            vm.organizations[orga.id] = orga
            vm.authorized_organizations[orga.id] = orga if MnoeOrganizations.role.atLeastPowerUser(orga.current_user_role)
        )

      # Check if the user is allowed to add apps to the given organization
      vm.isUserAuthorized = (orgId) ->
        currentUserRole = vm.organizations[orgId].current_user_role
        MnoeOrganizations.role.atLeastPowerUser(currentUserRole)

      # Change current organization
      vm.updateUserAuthorization = () ->
        vm.current_organization.isUserAuthorized = vm.isUserAuthorized(vm.current_organization.id)

      vm.changeOrganisation = ->
        MnoeOrganizations.get(vm.current_organization.id).then(
          (response) ->
        )

      vm.addApplication = ->
        MnoeOrganizations.purchaseApp(vm.app, vm.current_organization.id)

      # Check that the testimonial is not empty
      vm.isTestimonialShown = (testimonial) ->
        testimonial.text? && testimonial.text.length > 0

      # Return the different status of the app regarding its installation
      # - INSTALLABLE:  The app may be installed
      # - INSTALLED:    The app is already installed, and cannot be multi instantiated
      # - CONFLICT:     Another app, with a common subcategory that is not multi-instantiable has already been installed
      vm.appInstallationStatus = () ->
        if vm.appInstance
          if vm.app.multi_instantiable
            "INSTALLABLE"
          else
            if vm.app.app_nid != 'office-365' && vm.app.stack == 'connector' && !vm.app.oauth_keys_valid
              "INSTALLED_CONNECT"
            else
              "INSTALLED_LAUNCH"
        else
          if vm.conflictingApp
            "CONFLICT"
          else
            "INSTALLABLE"


      vm.provisionLink = () ->
        MnoeAppInstances.clearCache()

        # Get the authorization status for the current organization
        vm.current_organization.isUserAuthorized = vm.isUserAuthorized(vm.current_organization.id)
        if vm.current_organization.isUserAuthorized
          vm.addApplication()
        else  # Open a modal to change the organization
          vm.openChooseAppModal()

      vm.launchAppInstance = ->
        $window.open("/mnoe/launch/#{vm.appInstance.uid}", '_blank')

      #====================================
      # App Connect modal
      #====================================
      vm.connectAppInstance = ->
        templateUrl = switch
          when vm.appInstance.app_nid == "xero" then "app/views/apps/modals/app-connect-modal-xero.html"
          when vm.appInstance.app_nid == "myob" then "app/views/apps/modals/app-connect-modal-myob.html"
          else false
        vm.launchAppInstance() if !templateUrl

        modalInstance = $uibModal.open(
          templateUrl: templateUrl
          controller: 'DashboardAppConnectModalCtrl'
          resolve:
            app: ->
              vm.appInstance
        )

      vm.isPriceShown = PRICING_CONFIG && PRICING_CONFIG.enabled

      #====================================
      # Cart Management
      #====================================
      vm.cart = cart = {
        isOpen: false
        bundle: {}
        config: {}
      }

      # Open the ShoppingCart
      cart.open = ->
        cart.config.organizationId = MnoeOrganizations.selectedId
        cart.bundle = { app_instances: [{app: { id: vm.app.id }}] }
        cart.isOpen = true

      #====================================
      # Choose App Modal
      #====================================

      vm.openChooseAppModal = ->
        vm.chooseAppModalInstance = $uibModal.open({
          backdrop: 'static'
          size: 'lg'
          templateUrl: 'app/views/marketplace/modals/choose-orga-modal.html'
          windowClass: 'inverse'
          scope: $scope
        })

      vm.closeChooseAppModal = ->
        vm.chooseAppModalInstance.close()

      vm.cancelChooseAppModal = ->
        MnoeOrganizations.getCurrentId().then(
          (orgId) ->
            vm.current_organization.id = orgId
        )
        vm.chooseAppModalInstance.close()

      #====================================
      # Post-Initialization
      #====================================

      $scope.$watch MnoeOrganizations.getSelectedId, (val) ->
        if val?
          vm.isLoading = true
          # Retrieve the apps and the app instances in order to retrieve the current app, and its conflicting status
          # with the current installed app instances
          $q.all(
            marketplace: MnoeMarketplace.getApps(),
            appInstances: MnoeAppInstances.getAppInstances()
          ).then(
            (response)->
              apps = response.marketplace.apps
              appInstances = response.appInstances

              # App to be added
              appId = parseInt($stateParams.appId)
              app = _.findWhere(apps, { nid: $stateParams.appId })
              app ||= _.findWhere(apps, { id:  appId})

              # Find if we already have it
              appInstance = _.find(appInstances, { app_nid: app.nid})

              # Get the list of installed Apps
              nids = _.compact(_.map(appInstances, (a) -> a.app_nid))
              installedApps = _.filter(apps, (a) -> a.nid in nids)

              # Find conflicting app with the current app based on the subcategories
              # If there is already an installed app, with a common subcategory with the app that is not multi_instantiable
              # We keep that app, as a conflictingApp, to explain why the app cannot be installed.
              if app.subcategories
                # retrieve the subcategories names
                names = _.map(app.subcategories, 'name')

                conflictingApp = _.find(installedApps, (app) ->
                  _.find(app.subcategories, (subCategory) ->
                    not subCategory.multi_instantiable and subCategory.name in names
                  )
                )

              vm.initialize(app, appInstance, conflictingApp)
          )

      return
  )
