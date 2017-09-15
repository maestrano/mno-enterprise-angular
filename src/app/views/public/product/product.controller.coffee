angular.module 'mnoEnterpriseAngular'
  .controller('LandingProductCtrl',
    ($scope, $rootScope, $state, $stateParams, $window, MnoeConfig, MnoeMarketplace) ->

      vm = @
      vm.isLoading = true
      vm.averageRating = 5
      vm.isPriceShown = MnoeConfig.isPublicPricingEnabled()

      # Check that the testimonial is not empty
      vm.isTestimonialShown = (testimonial) ->
        testimonial.text? && testimonial.text.length > 0

      MnoeMarketplace.getApps().then(
        (response) ->

          # App to be displayed
          appId = $stateParams.productId
          vm.app = _.findWhere(response.apps, { nid: appId })
          vm.app ||= _.findWhere(response.apps, { id:  appId })

          # App rating
          vm.averageRating = parseFloat(vm.app.average_rating).toFixed(1)
          vm.isRateDisplayed = vm.averageRating ? vm.averageRating >= 0 : false
      ).finally(-> vm.isLoading = false)

      return
  )
