angular.module 'mnoEnterpriseAngular'
  .service 'AppManagementHelper', (PRICING_TYPES) ->
    _self = @

    @recentSubscription = (subscriptions) ->
      _.sortBy(subscriptions, 'created_at')[0]

    return @
