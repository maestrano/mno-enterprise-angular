angular.module('mnoEnterpriseAngular')
  .controller('DashboardMarketplaceCompareCtrl', ($scope, $stateParams, $state, MnoeMarketplace, MnoeConfig) ->

    vm = this

    # Enabling pricing
    vm.isPriceShown = MnoeConfig.isMarketplacePricingEnabled()
    # Enabling reviews
    vm.isReviewingEnabled = MnoeConfig.areMarketplaceReviewsEnabled()

    #====================================
    # Initialization
    #====================================
    vm.isLoading = true

    currency = MnoeConfig.marketplaceCurrency()
    vm.pricing_plans = [currency] || 'AUD' || 'default'

    #====================================
    # Calls
    #====================================
    MnoeMarketplace.getApps().then(
      (response) ->
        response = response.plain()
        # Filter apps selected
        vm.comparedApps = _.each(
          _.filter(response.apps, (app)-> app.toCompare == true),
            (app) ->  # Round average rating
              app.average_rating = if app.average_rating? then parseFloat(app.average_rating).toFixed(1)
              true
        )

        vm.isLoading = false
    )

    return
  )
