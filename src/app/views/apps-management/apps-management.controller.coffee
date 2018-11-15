angular.module 'mnoEnterpriseAngular'
  .controller('AppsManagementCtrl',
    ($q, $scope, MnoeConfig, MnoeProductInstances, MnoeProvisioning, MnoeOrganizations, AppManagementHelper) ->

      vm = @
      vm.isLoading = true
      vm.recentSubscription = AppManagementHelper.recentSubscription

      vm.providesStatus = (product) ->
        vm.dataSharingEnabled(product) || product.subscription

      vm.dataSharingEnabled = (product) ->
        MnoeConfig.isDataSharingEnabled() && product.data_sharing

      vm.subscriptionStatus = (product) ->
        return product.subscription.status if product.subscription

      vm.appActionUrl = (product) ->
        "/mnoe/launch/#{product.uid}"

      vm.init = ->
        productPromise = MnoeProductInstances.getProductInstances()
        subPromise = if MnoeOrganizations.role.atLeastAdmin() then MnoeProvisioning.getSubscriptions() else null

        $q.all({products: productPromise, subscriptions: subPromise}).then(
          (response) ->
            vm.products = _.map(response.products,
              (product) ->
                product_subscriptions = _.filter(response.subscriptions, (subscription) -> subscription.product_instance_id == product.id)
                if product_subscriptions
                  fulfilled_subs = _.filter(product_subscriptions, { status: 'fulfilled'} )
                  product.subscription = if fulfilled_subs.length > 0
                    vm.recentSubscription(fulfilled_subs)
                  else
                    vm.recentSubscription(product_subscriptions)

                AppManagementHelper.setProductSyncStatuses([product])[0]
            )
        ).finally(
          ->
            vm.isLoading = false
          )

      #====================================
      # Post-Initialization
      #====================================
      $scope.$watch MnoeOrganizations.getSelectedId, (val) ->
        if val?
          vm.isLoading = true
          vm.init()

      return
  )
