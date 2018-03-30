angular.module 'mnoEnterpriseAngular'
  .controller('AppManagementCtrl',
    ($q, MnoeConfig, MnoeAppInstances, MnoeProvisioning) ->

      vm = @
      vm.isLoading = true

      vm.providesStatus = (app) ->
        app.data_sharing || app.subscription

      # TODO: Change the data sharing to be based on feature flag.
      vm.dataSharingStatus = (app) ->
        if app.data_sharing
          'Connected'
        else
          'Disconnected'

      vm.subscriptionStatus = (app) ->
        return app.subscription.status if app.subscription

      vm.appActionUrl = (app) ->
        "/mnoe/launch/#{app.uid}"

      appPromise = MnoeAppInstances.getAppInstances()
      subPromise = MnoeProvisioning.getSubscriptions()

      $q.all({apps: appPromise, subscriptions: subPromise}).then(
        (response) ->
          vm.apps = _.each(response.apps,
            (app) ->
              app.subscription = _.find(response.subscriptions, product?.nid == app.app_nid)
              app
          )
      ).finally(-> vm.isLoading = false)

      return
  )
