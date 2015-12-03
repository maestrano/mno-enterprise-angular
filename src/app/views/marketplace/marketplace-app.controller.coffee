#============================================
#
#============================================
angular.module 'mnoEnterpriseAngular'
  .controller('DashboardMarketplaceAppCtrl',
    ($stateParams, $sce, MnoeMarketplace, DhbOrganizationSvc) ->

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

      # Check that the testimonial is not empty
      vm.isTestimonialShown = (testimonial) ->
        testimonial.text? && testimonial.text.length > 0

      vm.provisionLink = () ->
        "/mnoe/provision/new?apps[]=#{vm.app.nid}&organization_id=#{DhbOrganizationSvc.getId()}"

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
        if (d = DhbOrganizationSvc.data) && (o = d.organization) && o.id
          cart.config.organizationId = o.id

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
