angular.module 'mnoEnterpriseAngular'
  .controller('DashboardMarketplaceCompareCtrl', ($scope, $stateParams, $state,
    MnoeMarketplace, PRICING_CONFIG, REVIEWS_CONFIG) ->

      vm = this

      # Enabling pricing
      vm.isPriceShown = PRICING_CONFIG && PRICING_CONFIG.enabled
      # Enabling reviews
      vm.isReviewingEnabled = REVIEWS_CONFIG && REVIEWS_CONFIG.enabled

      #====================================
      # Initialization
      #====================================
      vm.isLoading = true

      currency = (PRICING_CONFIG && PRICING_CONFIG.currency) || 'AUD'
      vm.pricing_plans = [currency] || 'AUD' || 'default'

      #====================================
      # Calls
      #====================================
      MnoeMarketplace.getApps().then(
        (response) ->
          response = response.plain()
          # Filter apps selected
          vm.compared_apps = _.each(
            _.filter(response.apps, (app)-> app.toCompare == true),
            (app) ->  # Round average rating
              app.average_rating = Math.round( app.average_rating * 10 ) / 10;
              true
          )

          vm.isLoading = false
      )

      return
  )
