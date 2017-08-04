# Service for managing the users.
angular.module 'mnoEnterpriseAngular'
  .service 'MnoeProvisioning', ($q, $log, MnoeApiSvc, MnoeOrganizations, MnoErrorsHandler) ->
    _self = @

    subscriptionsApi = (id) -> MnoeApiSvc.one('/organizations', id).all('subscriptions')

    productsApi = MnoeApiSvc.oneUrl('/products')
    productsPromise = null
    productsResponse = null

    subscription = {}

    defaultSubscription = {
      id: null
      product: null
      product_pricing: null
      custom_data: {}
    }

    # Return the list of product
    @getProducts = () ->
      return productsPromise if productsPromise?
      productsPromise = productsApi.get().then(
        (response) ->
          productsResponse = response.plain()
          response
      )

    # Find a product using its id or nid
    @findProduct = ({id = null, nid = null}) ->
      _self.getProducts().then(
        ->
          _.find(productsResponse.products, (a) -> a.id == id || a.nid == nid)
      )

    @setSubscription = (s) ->
      subscription = s

    @getSubscription = () ->
      subscription

    # Return the subscription
    # if productNid: return the default subscription
    # if subscriptionId: return the fetched subscription
    # else: return the subscription in cache (edition mode)
    @initSubscription = ({productNid = null, subscriptionId = null}) ->
      deferred = $q.defer()

      if productNid?
        # Create a new subscription to a product
        angular.copy(defaultSubscription, subscription)
        deferred.resolve(subscription)
      else if subscriptionId?
        # Edit a subscription
        _self.fetchSubscription(subscriptionId).then(
          (response) ->
            angular.copy(response, subscription)
            deferred.resolve(subscription)
        )
      else
        deferred.resolve(subscription)
      return deferred.promise

    @createSubscription = (s) ->
      deferred = $q.defer()
      MnoeOrganizations.get().then(
        (response) ->
          subscriptionsApi(response.organization.id).post({subscription: {product_pricing_id: s.product_pricing.id, custom_data: s.custom_data}}).then(
            (response) ->
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
              deferred.resolve(response)
          )
      )
      return deferred.promise

    # Detect if the subscription should be a POST or A PUT and call corresponding method
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
              deferred.resolve(response)
          )
      )
      return deferred.promise

    @cancelSubscription = (s) ->
      deferred = $q.defer()
      MnoeOrganizations.get().then(
        (response) ->
          MnoeApiSvc.one('/organizations', response.organization.id).one('subscriptions', s.id).post('cancel').then(
            (response) ->
              deferred.resolve(response)
            (error) ->
              MnoErrorsHandler.processServerError(error)
              deferred.reject(response)
          )
      )
      return deferred.promise

    return
