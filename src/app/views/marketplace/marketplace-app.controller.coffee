#============================================
#
#============================================
angular.module 'mnoEnterpriseAngular'
  .controller('DashboardMarketplaceAppCtrl',
    ($q, $scope, $stateParams, $sce, $window, MnoeMarketplace, MnoeOrganizations, MnoeAppInstances, PRICING_CONFIG) ->

      vm = this

      #====================================
      # Pre-Initialization
      #====================================
      vm.isLoading = true
      vm.app = {}
      # The already installed app instance of the app, if any
      vm.appInstance = null
      # An already installed app instance, conflicting with the app because it contains a common subcategory
      # that is not multi instantiable, if any
      vm.conflictingAppInstance = null
      #====================================
      # Scope Management
      #====================================
      vm.initialize = (app, appInstance, conflictingAppInstance) ->
        angular.copy(app, vm.app)
        vm.appInstance = appInstance
        vm.conflictingAppInstance = conflictingAppInstance
        vm.app.description = $sce.trustAsHtml(app.description)
        vm.isLoading = false
        plans = vm.app.pricing_plans
        currency = (PRICING_CONFIG && PRICING_CONFIG.currency) || 'AUD'
        vm.pricing_plans = plans[currency] || plans.AUD || plans.default

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
            "INSTALLED"
        else
          if vm.conflictingAppInstance
            "CONFLICT"
          else
            "INSTALLABLE"

      vm.provisionLink = () ->
        MnoeAppInstances.clearCache()
        $window.location.href = "/mnoe/provision/new?apps[]=#{vm.app.nid}&organization_id=#{MnoeOrganizations.selectedId}"

      vm.launchAppInstance = () ->
        $window.open("/mnoe/launch/#{vm.appInstance.uid}", '_blank')

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
      # Post-Initialization
      #====================================

      $scope.$watch MnoeOrganizations.getSelectedId, (val) ->
        if val?
          vm.isLoading = true
          # Retrieve the apps and the app instances in order to retrieve the current app, and its conflicting status
          # with the current installed app instances
          $q.all([MnoeMarketplace.getApps(), MnoeAppInstances.getAppInstances()]).then(
            (response)->
              apps = response[0].apps
              appInstances = response[1]
              appId = parseInt($stateParams.appId)
              appsPerNid = {}
              appsPerNid[a.nid] = a for a in apps

              app = _.findWhere(apps, { slug: $stateParams.appId })
              app ||= _.findWhere(apps, { id:  appId})
              appInstance = _.find(appInstances, { app_nid: app.nid})
              # Find conflicting app instance with the current app based on the subcategories
              # If there is already an insalled app instance, with a common subcategory with the app that is not multi_instantiable
              # We keep that appInstance, as a conflictingAppInstance, to explain why the app cannot be installed.
              if app.subcategories
                # retrieve the subcategories names
                names = app.subcategories.map (c) -> c.name
                conflictingAppInstance = _.find(appInstances, (appInst) ->
                  appInstanceApp = appsPerNid[appInst.app_nid]
                  _.find(appInstanceApp.subcategories, (subCategory) ->
                    not subCategory.multi_instantiable and subCategory.name in names
                  )
                )
              vm.initialize(app, appInstance, conflictingAppInstance)
          )

      return
  )
