angular.module 'mnoEnterpriseAngular'
  .controller('AppManagementCtrl',
    ($q, $stateParams, MnoeConfig, MnoeAppInstances, MnoeProvisioning, MnoeOrganizations) ->

      vm = @
      vm.isLoading = true
      vm.isOrderHistoryLoading = true

      vm.providesStatus = (app) ->
        app.data_sharing || app.subscription

      # TODO: Decide how data sharing status is checked
      vm.dataSharingStatus = ->
        if vm.app.data_sharing
          'Connected'
        else
          'Disconnected'

      vm.subscriptionStatus = (app) ->
        return app.subscription.status if app.subscription

      vm.appActionUrl = (app) ->
        "/mnoe/launch/#{app.uid}"

      vm.dataSharingEnabled = ->
        MnoeConfig.isDataSharingEnabled() && vm.app.data_sharing

      vm.loadOrderHistory = ->
        # TODO: Hit the MnoeProvisioning.getProductSubscriptions(ProductID)
        #       to get the subscriptions for that product and load data from
        #       that in order hsitroy. Add a new loader bool to load this data
        #       i.e. isOrderHistoryLoading = true
        MnoeProvisioning.getProductSubscriptions(vm.app.app_id).then(
          (response) ->
            vm.subscriptionsHistory = response
            console.log 'vm.subscriptionsHistory'
            console.log vm.subscriptionsHistory
        ).finally( -> vm.isOrderHistoryLoading = false)

      appPromise = MnoeAppInstances.getAppInstances()
      subPromise = MnoeProvisioning.getSubscriptions()
      orgPromise = MnoeOrganizations.get(MnoeOrganizations.selectedId)

      $q.all({apps: appPromise, subscriptions: subPromise, organization: orgPromise}).then(
        (response) ->
          vm.app = _.find(response.apps, { id: $stateParams.appId })
          console.log 'vm.app'
          console.log vm.app
          vm.organization = response.organization.organization

          # Starting subscription flow
          MnoeProvisioning.initSubscription({productNid: vm.app.id, subscriptionId: $stateParams.id})

          # Order Histroy flow
          vm.loadOrderHistory()
      ).finally(-> vm.isLoading = false)

      return
  )
