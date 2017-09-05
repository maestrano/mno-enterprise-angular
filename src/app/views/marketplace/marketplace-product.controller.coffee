#============================================
#
#============================================
angular.module 'mnoEnterpriseAngular'
  .controller('DashboardMarketplaceProductCtrl',($scope, $q, $stateParams, $state, MnoeMarketplace, MnoeOrganizations, MnoeConfig) ->

    vm = this

    vm.isPriceShown = MnoeConfig.isMarketplacePricingEnabled()

    #====================================
    # Post-Initialization
    #====================================
    $scope.$watch MnoeOrganizations.getSelectedId, (val) ->
      if val?
        vm.isLoading = true
        MnoeOrganizations.get()


        # Retrieve the products
        $q.all({
          organization: MnoeOrganizations.get(),
          localProducts: MnoeMarketplace.getLocalProducts()
        }).then(
          (response) ->
            products = response.localProducts
            organization = response.organization

            vm.orgCurrency = organization.billing?.current?.options?.iso_code || MnoeConfig.marketplaceCurrency()

            # App to be displayed
            productId = $stateParams.productId
            vm.product = _.findWhere(products, { nid: productId })
            vm.product ||= _.findWhere(products, { id:  productId })

            $state.go('home.marketplace') unless vm.product?
        ).finally(-> vm.isLoading = false)

      return
  )
