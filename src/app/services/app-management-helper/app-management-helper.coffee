angular.module 'mnoEnterpriseAngular'
  .service 'AppManagementHelper', (PRICING_TYPES) ->
    _self = @

    @recentSubscription = (subscriptions) ->
      _.sortBy(subscriptions, 'created_at')[0]

    @isProductConnected = (product) ->
      product.sync_status.attributes.status.toLowerCase() == 'connected'

    @setProductSyncStatuses = (products) ->
      setSyncStatus = (product) ->
        syncStatus = if !product?.sync_status || product.sync_status.attributes.status.toLowerCase() in ['error', 'disconnected']
          'Disconnected'
        else
          'Connected'

        if product.sync_status
          product.sync_status.attributes.status = syncStatus
        else
          # Set default value of sync date to null if no sync status is attached
          product.sync_status = {
            attributes: { status: syncStatus, finished_at: null }
          }

        product

      (setSyncStatus(product) for product in products)


    return @
