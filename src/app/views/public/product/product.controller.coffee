angular.module 'mnoEnterpriseAngular'
  .controller('LandingProductCtrl',
    ($scope, $rootScope, $state, $stateParams, $window, MnoeConfig, MnoeMarketplace) ->
      unless MnoeConfig.arePublicPagesEnabled()
        $window.location = URI.login

      vm = @
      vm.averageRating = 5
      vm.isPriceShown = MnoeConfig.isPublicPricingEnabled()
      $rootScope.publicPage = true

      # Check that the testimonial is not empty
      vm.isTestimonialShown = (testimonial) ->
        testimonial.text? && testimonial.text.length > 0

      MnoeMarketplace.getApps().then(
        (response) ->
          vm.app = MnoeMarketplace.findApp($stateParams.productId)
          vm.averageRating = vm.app.average_rating
          vm.isRateDisplayed = vm.averageRating >= 0
      )

      return
  )
