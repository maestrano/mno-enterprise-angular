#============================================
#
#============================================
angular.module 'mnoEnterpriseAngular'
  .controller('DashboardMarketplaceAppCtrl',($q, $scope, $stateParams, $state, $sce, $window, toastr,
    MnoeMarketplace, $uibModal, MnoeOrganizations, MnoeCurrentUser, MnoeAppInstances, MnoErrorsHandler, PRICING_CONFIG) ->

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
      # Enabling pricing
      vm.isPriceShown = PRICING_CONFIG && PRICING_CONFIG.enabled
      vm.averageRating = 5

      #====================================
      # Scope Management
      #====================================
      vm.initialize = (app, appInstance, conflictingApp) ->
        # Variables initialization
        vm.reviews =
          loading: true
          nbItems: 5
          page: 1
          pageChangedCb: (appId, nbItems, page) ->
            vm.reviews.nbItems = nbItems
            vm.reviews.page = page
            offset = (page  - 1) * nbItems
            fetchReviews(appId, nbItems, offset)

        vm.app = app

        # Fetch initials reviews
        fetchReviews(app.id, vm.reviews.nbItems, 0)
        vm.averageRating = parseFloat(vm.app.average_rating).toFixed(1)
        vm.isRateDisplayed = vm.averageRating?

        vm.appInstance = appInstance
        vm.conflictingApp = conflictingApp
        vm.app.description = $sce.trustAsHtml(app.description)
        plans = vm.app.pricing_plans
        currency = (PRICING_CONFIG && PRICING_CONFIG.currency) || 'AUD'
        vm.pricing_plans = plans[currency] || plans.AUD || plans.default

        # Get the user role in this organization
        MnoeOrganizations.get().then((response) -> vm.user_role = response.current_user.role)

        vm.isLoading = false

        # Check that the testimonial is not empty
        vm.isTestimonialShown = (testimonial) ->
          testimonial.text? && testimonial.text.length > 0

        # Return the different status of the app regarding its installation
        # - INSTALLABLE:  The app may be installed
        # - INSTALLED_CONNECT/INSTALLED_LAUNCH: The app is already installed, and cannot be multi instantiated
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

        vm.provisionApp = () ->
          vm.isLoadingButton = true
          MnoeAppInstances.clearCache()

          # Get the authorization status for the current organization
          if MnoeOrganizations.role.atLeastPowerUser(vm.user_role)
            purchasePromise = MnoeOrganizations.purchaseApp(vm.app, MnoeOrganizations.selectedId)
          else  # Open a modal to change the organization
            purchasePromise = openChooseOrgaModal().result

          purchasePromise.then(
            ->
              $state.go('home.impac')

              switch vm.app.stack
                when 'cloud' then displayLaunchToastr(vm.app)
                when 'cube' then displayLaunchToastr(vm.app)
                when 'connector'
                  if vm.app.nid == 'office-365'
                    # Office 365 must display 'Launch'
                    displayLaunchToastr(vm.app)
                  else
                    displayConnectToastr(vm.app)
            (error) ->
              toastr.error(vm.app.name + " has not been added, please try again.")
              MnoErrorsHandler.processServerError(error)
          ).finally(-> vm.isLoadingButton = false)

        displayLaunchToastr = (app) ->
          toastr.success(
            'mno_enterprise.templates.dashboard.marketplace.show.success_launch_notification_body',
            'mno_enterprise.templates.dashboard.marketplace.show.success_notification_title',
            {extraData: {name: app.name}, timeout: 10000}
          )

        displayConnectToastr = (app) ->
          toastr.success(
            'mno_enterprise.templates.dashboard.marketplace.show.success_connect_notification_body',
            'mno_enterprise.templates.dashboard.marketplace.show.success_notification_title',
            {extraData: {name: app.name}, timeout: 10000}
          )

        vm.launchAppInstance = ->
          $window.open("/mnoe/launch/#{vm.appInstance.uid}", '_blank')

        openChooseOrgaModal = ->
          $uibModal.open(
            backdrop: 'static'
            templateUrl: 'app/views/marketplace/modals/choose-orga-modal.html'
            controller: 'MarketplaceChooseOrgaModalCtrl'
            resolve:
              app: vm.app
          )

        #====================================
        # App Connect modal
        #====================================
        vm.connectAppInstance = ->
          switch vm.appInstance.app_nid
            when "xero" then modalInfo = {
              template: "app/views/apps/modals/app-connect-modal-xero.html",
              controller: 'DashboardAppConnectXeroModalCtrl'
            }
            when "myob" then modalInfo = {
              template: "app/views/apps/modals/app-connect-modal-myob.html",
              controller: 'DashboardAppConnectMyobModalCtrl'
            }
            else vm.launchAppInstance()

          $uibModal.open(
            templateUrl: modalInfo.template
            controller: modalInfo.controller
            resolve:
              app: vm.appInstance
          )

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
      # Reviews
      #====================================
      vm.openCreateReviewModal = ->
        modalInstance = $uibModal.open(
          templateUrl: 'app/views/marketplace/modals/create-review-modal.html'
          controller: 'CreateReviewModalCtrl'
          controllerAs: 'vm',
          size: 'lg'
          windowClass: 'inverse'
          backdrop: 'static'
        )
        modalInstance.result.then(
          (response) ->
            # Increment # of items
            vm.reviews.totalItems++
            # Add new element at the beginning
            vm.reviews.list.unshift(response.app_review)
            # Remove last element if needed
            vm.reviews.list.pop() if vm.reviews.list.length > vm.reviews.nbItems
            # Update average rating
            vm.averageRating = parseFloat(response.average_rating).toFixed(1)
        )

      fetchReviews = (appId, limit, offset, sort = 'created_at.desc') ->
        vm.reviews.loading = true
        MnoeMarketplace.getReviews(appId, limit, offset, sort).then(
          (response) ->
            vm.reviews.totalItems = response.headers('x-total-count')
            vm.reviews.list = response.data
        ).finally(-> vm.reviews.loading = false)

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
