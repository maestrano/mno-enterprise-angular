angular.module 'mnoEnterpriseAngular'
  .controller('AppsManagementCtrl',
    ($q, $scope, MnoeConfig, MnoeProductInstances, MnoeProvisioning, MnoeOrganizations, AppManagementHelper, MnoeAppInstances) ->

      vm = @
      vm.isLoading = true
      vm.syncStatusesSet = false
      vm.recentSubscription = AppManagementHelper.recentSubscription

      vm.providesStatus = (product) ->
        vm.dataSharingEnabled(product) || product.subscription

      vm.dataSharingEnabled = (product) ->
        MnoeConfig.isDataSharingEnabled() && product.data_sharing

      vm.subscriptionStatus = (product) ->
        return product.subscription.status if product.subscription

      vm.appActionUrl = (product) ->
        "/mnoe/launch/#{product.uid}"

      vm.initAppInstanceSync = ->
        MnoeAppInstances.getAppInstanceSync().then(
          (response) ->
            vm.connecApps = response.connectors
            vm.products = AppManagementHelper.setProductSyncStatuses(vm.connecApps, vm.products)
        ).finally(-> vm.syncStatusesSet = true)

      vm.init = ->
        productPromise = MnoeProductInstances.getProductInstances()
        subPromise = if MnoeOrganizations.role.atLeastAdmin() then MnoeProvisioning.getSubscriptions() else null

        $q.all({products: productPromise, subscriptions: subPromise}).then(
          (response) ->
            vm.products = _.map(response.products,
              (product) ->
                product_subscriptions = _.filter(response.subscriptions, (subscription) -> subscription.product?.nid == product.product_nid)
                if product_subscriptions
                  fulfilled_subs = _.filter(product_subscriptions, { status: 'fulfilled'} )
                  product.subscription = if fulfilled_subs.length > 0
                    vm.recentSubscription(fulfilled_subs)
                  else
                    vm.recentSubscription(product_subscriptions)

                product
            )
        ).finally(
          ->
            vm.isLoading = false
            vm.initAppInstanceSync()
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
