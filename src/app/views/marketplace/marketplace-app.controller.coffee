#============================================
#
#============================================
angular.module 'mnoEnterpriseAngular'
  .controller('DashboardMarketplaceAppCtrl',
    ($q, $stateParams, $sce, $window, MnoeMarketplace, MnoeOrganizations, MnoeAppInstances, PRICING_CONFIG) ->

      vm = this

      #====================================
      # Pre-Initialization
      #====================================
      vm.isLoading = true
      vm.app = {}
      vm.appInstance = null
      #====================================
      # Scope Management
      #====================================
      vm.initialize = (app, appInstance) ->
        angular.copy(app, vm.app)
        vm.appInstance = appInstance
        vm.app.description = $sce.trustAsHtml(app.description)
        vm.isLoading = false
        plans = vm.app.pricing_plans
        currency = (PRICING_CONFIG && PRICING_CONFIG.currency) || 'AUD'
        vm.pricing_plans = plans[currency] || plans.AUD || plans.default

      # Check that the testimonial is not empty
      vm.isTestimonialShown = (testimonial) ->
        testimonial.text? && testimonial.text.length > 0

      vm.isApplicationAlreadyInstalled = () ->
        !vm.app.multi_instantiable && vm.appInstance

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

      $q.all([MnoeMarketplace.getApps(), MnoeAppInstances.getAppInstances()]).then(
        (response)->
          apps = response[0].apps
          appInstances = response[1]
          appId = parseInt($stateParams.appId)
          app = _.findWhere(apps, { slug: $stateParams.appId })
          app ||= _.findWhere(apps, { id:  appId})
          appInstance = _.find(appInstances, { app_nid: app.nid})
          vm.initialize(app, appInstance)
      )



      return
  )
