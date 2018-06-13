angular.module 'mnoEnterpriseAngular'
  .controller('AppsManagementCtrl',
    ($q, $scope, MnoeConfig, MnoeProductInstances, MnoeProvisioning, MnoeOrganizations, AppManagementHelper, MnoeAppInstances) ->

      vm = @
      vm.isLoading = true
      vm.recentSubscription = AppManagementHelper.recentSubscription

      getSyncStatusValue = (product) ->
        sync_status = _.find(vm.connec_apps, (app) -> app.uid == product.uid)
        return 'Disconnected' unless sync_status

        if sync_status.status.toLowerCase() in ['error', 'disconnected']
          'Disconnected'
        else
          'Connected'

      getSyncStatuses = ->
        vm.products = _.map(vm.products,
          (product) ->
            if product.uid in vm.filterSyncProductIds
              product.sync_status = {}
              product.sync_status.attributes = {}
              product.sync_status.attributes.status = getSyncStatusValue(product)
            product
        )

      vm.providesStatus = (product) ->
        vm.dataSharingEnabled(product) || product.subscription

      vm.dataSharingEnabled = (product) ->
        MnoeConfig.isDataSharingEnabled() && product.data_sharing

      vm.dataSharingStatus = (product) ->
        # If sync status is set from backend then it follows following:
        # sync_status values:
        #   null => disconnected
        #   all other values => connected
        if _.find(vm.filterSyncProductIds, (uid) -> uid == product.uid)
          product.sync_status?.attributes?.status
        else
          if product.sync_status?.attributes?.status
            'Connected'
          else
            'Disconnected'

      vm.subscriptionStatus = (product) ->
        return product.subscription.status if product.subscription

      vm.appActionUrl = (product) ->
        "/mnoe/launch/#{product.uid}"

      vm.initAppInstanceSync = ->
        vm.filterSyncProductIds = _.map(_.filter(vm.products, (product) -> !product.sync_status), (prod) -> prod.uid)
        return if vm.filterSyncProductIds.length == 0

        MnoeAppInstances.getAppInstanceSync().then(
          (response) ->
            vm.connec_apps = response.connectors
            getSyncStatuses()
        )

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
