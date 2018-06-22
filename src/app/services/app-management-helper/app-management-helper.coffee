angular.module 'mnoEnterpriseAngular'
  .service 'AppManagementHelper', (PRICING_TYPES) ->
    _self = @

    @recentSubscription = (subscriptions) ->
      _.sortBy(subscriptions, 'created_at')[0]

    @setProductSyncStatuses = (connecAppInstances, products) ->
      setSyncStatus = (product) ->
        # Don't use product instance sync status as it will not always be up to date
        # until connector framework is modified to keep it up to date
        connecStatus = _.find(connecAppInstances, (appInstance) -> appInstance.uid == product.uid)
        syncStatus = if !connecStatus?.status || connecStatus.status.toLowerCase() in ['error', 'disconnected']
          'Disconnected'
        else
          'Connected'

        product.sync_status = {
          attributes: {status: syncStatus, finished_at: connecStatus?.last_sync_date}
        }

        product

      (setSyncStatus(product) for product in products)


    return @
