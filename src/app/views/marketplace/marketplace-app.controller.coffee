#============================================
#
#============================================
angular.module 'mnoEnterpriseAngular'
  .controller('DashboardMarketplaceAppCtrl',
    ($stateParams, $sce, $window, MnoeMarketplace, MnoeOrganizations, MnoeAppInstances, PRICING_CONFIG) ->

      vm = this

      #====================================
      # Pre-Initialization
      #====================================
      vm.isLoading = true
      vm.app = {}

      #====================================
      # Scope Management
      #====================================
      vm.initialize = (app) ->
        angular.copy(app, vm.app)
        vm.app.description = $sce.trustAsHtml(app.description)
        vm.isLoading = false
        plans = vm.app.pricing_plans
        currency = (PRICING_CONFIG && PRICING_CONFIG.currency) || 'AUD'
        vm.pricing_plans = plans[currency] || plans.AUD || plans.default

      # Check that the testimonial is not empty
      vm.isTestimonialShown = (testimonial) ->
        testimonial.text? && testimonial.text.length > 0

      vm.provisionLink = () ->
        MnoeAppInstances.clearCache()
        $window.location.href = "/mnoe/provision/new?apps[]=#{vm.app.nid}&organization_id=#{MnoeOrganizations.selectedId}"

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
      MnoeMarketplace.getApps($stateParams.appId).then(
        (response)->
          app = _.findWhere(response.apps, { slug: $stateParams.appId })
          app ||= _.findWhere(response.apps, { id: parseInt($stateParams.appId) })
          vm.initialize(app)
      )

      return
  )
