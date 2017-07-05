# Service for managing the users.
angular.module 'mnoEnterpriseAngular'
  .service 'MnoeProvisioning', ($q, $log, MnoeApiSvc, MnoeOrganizations) ->
    _self = @

    subscriptionsApi = (id) -> MnoeApiSvc.one('/organizations', id).all('subscriptions')

    productsApi = MnoeApiSvc.oneUrl('/products')
    productsPromise = null
    productsResponse = null

    subscription = {
      product: null
      product_pricings: null
      custom_data: {}
    }

    @getProducts = () ->
      return productsPromise if productsPromise?
      productsPromise = productsApi.get().then(
        (response) ->
          productsResponse = response.plain()
          response
      )

    @findProduct = ({id = null, nid = null}) ->
      _self.getProducts().then(
        ->
          _.find(productsResponse.products, (a) -> a.id == id || a.nid == nid)
      )

    @setSubscription = (s) ->
      subscription = s

    @getSubscription = () ->
      subscription

    @initSubscription = ({productNid = null, subscriptionId = null}) ->
      deferred = $q.defer()
      if productNid?
        # Create a new subscription to a product
        deferred.resolve(subscription)
      else if subscriptionId?
        # Edit a subscription
        _self.fetchSubscription(subscriptionId).then(
          (response) -> deferred.resolve(response)
        )
      return deferred.promise

    @createSubscription = (s) ->
      deferred = $q.defer()
      MnoeOrganizations.get().then(
        (response) ->
          subscriptionsApi(response.organization.id).post({subscription: {product_pricing_id: s.product_pricing.id, custom_data: s.custom_data}}).then(
            (response) ->
              console.log("### DEBUG post response", response)
              deferred.resolve(response)
          )
      )
      return deferred.promise

    @updateSubscription = (s) ->
      deferred = $q.defer()
      MnoeOrganizations.get().then(
        (response) ->
          subscription.patch({subscription: {product_pricing_id: s.product_pricing.id, custom_data: s.custom_data}}).then(
            (response) ->
              console.log("### DEBUG put response", response)
              deferred.resolve(response)
          )
      )
      return deferred.promise

    @saveSubscription = (subscription) ->
      unless subscription.id
        _self.createSubscription(subscription)
      else
        _self.updateSubscription(subscription)

    @fetchSubscription = (id) ->
      deferred = $q.defer()
      MnoeOrganizations.get().then(
        (response) ->
          MnoeApiSvc.one('/organizations', response.organization.id).one('subscriptions', id).get().then(
            (response) ->
              console.log("### DEBUG get response", response)
              deferred.resolve(response)
          )
      )
      return deferred.promise

    @getSubscriptions = () ->
      deferred = $q.defer()
      MnoeOrganizations.get().then(
        (response) ->
          subscriptionsApi(response.organization.id).getList().then(
            (response) ->
              console.log("### DEBUG getList response", response)
              deferred.resolve(response)
          )
      )
      return deferred.promise

    return
