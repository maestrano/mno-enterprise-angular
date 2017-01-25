angular.module 'mnoEnterpriseAngular'
  .controller('DashboardMarketplaceCompareCtrl', ($scope, $stateParams, $state,
    MnoeMarketplace, PRICING_CONFIG) ->

      vm = this

      vm.isPriceShown = PRICING_CONFIG && PRICING_CONFIG.enabled

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
          # Remove restangular decoration
          response = response.plain()

          vm.categories = response.categories
          vm.apps = response.apps

          vm.isLoading = false

      )

      return
  )
