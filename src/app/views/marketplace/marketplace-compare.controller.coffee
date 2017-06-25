angular.module('mnoEnterpriseAngular')
  .controller('DashboardMarketplaceCompareCtrl', ($scope, $stateParams, $state, MnoeMarketplace, DASHBOARD_CONFIG) ->

    vm = this

    # Enabling pricing
    vm.isPriceShown = DASHBOARD_CONFIG.marketplace?.pricing?.enabled
    # Enabling reviews
    vm.isReviewingEnabled = DASHBOARD_CONFIG.marketplace?.reviews?.enabled

    #====================================
    # Initialization
    #====================================
    vm.isLoading = true

    currency = (DASHBOARD_CONFIG.marketplace?.pricing?.currency) || 'AUD'
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
              app.average_rating = parseFloat(app.average_rating).toFixed(1)
              true
        )

        vm.isLoading = false
    )

    return
  )
