# Service for managing the users.
angular.module 'mnoEnterpriseAngular'
  .service 'MnoeProvisioning', ($q, $log, MnoeApiSvc, MnoeOrganizations, MnoErrorsHandler) ->
    _self = @

    subscriptionsApi = (id) -> MnoeApiSvc.one('/organizations', id).all('subscriptions')

    subscription = {}
    selectedCurrency = ""
    quote = {}

    @cartSubscriptionsPromise = null

    defaultSubscription = {
      id: null
      product: null
      product_pricing: null
      custom_data: {}
    }

    @getCartSubscriptionsPromise = ->
      _self.cartSubscriptionsPromise

    @setSubscription = (s) ->
      subscription = s

    @getCachedSubscription = () ->
      subscription

    @setSelectedCurrency = (c) ->
      selectedCurrency = c

    @getSelectedCurrency = () ->
      selectedCurrency

    @setQuote = (q) ->
      quote = q

    @getCachedQuote = () ->
      { price: quote?.quote, currency: quote?.currency }

    # Return the subscription
    # if productNid: return the default subscription
    # if subscriptionId: return the fetched subscription
    # else: return the subscription in cache (edition mode)
    @initSubscription = ({productId = null, subscriptionId = null, cart = null}) ->
      deferred = $q.defer()
      # Edit a subscription
      if !_.isEmpty(subscription)
        deferred.resolve(subscription)
      else if subscriptionId?
        _self.fetchSubscription(subscriptionId, cart).then(
          (response) ->
            angular.copy(response, subscription)
            deferred.resolve(subscription)
        )
      else if productId?
        # Create a new subscription to a product
        angular.copy(defaultSubscription, subscription)
        deferred.resolve(subscription)
      else
        deferred.resolve({})

      return deferred.promise

    subscriptionParams = (s, c) ->
      {
        subscription: {
          product_id: s.product.id,
          cart_entry: s.cart_entry,
          subscription_events_attributes: [subscriptionEventParams(s, c)]
        }
      }

    subscriptionEventParams = (s, c) ->
      {
        event_type: s.event_type,
        product_pricing_id: s.product_pricing?.id,
        subscription_details: {
          start_date: s.start_date,
          custom_data: s.custom_data,
          currency: c,
          max_licenses: s.max_licenses
        }
      }

    @createSubscription = (s, c) ->
      deferred = $q.defer()
      MnoeOrganizations.get().then(
        (response) ->
          subscriptionsApi(response.organization.id).post(subscriptionParams(s,c)).then(
            (response) ->
              deferred.resolve(response)
          )
      )
      return deferred.promise

    @createSubscriptionEvent = (s, c) ->
      deferred = $q.defer()
      MnoeOrganizations.get().then((response) ->
        MnoeApiSvc.one('organizations', response.organization.id).one('subscriptions', s.id).all('subscription_events')
          .post({subscription_event: subscriptionEventParams(s,c)}).then((response) ->
            deferred.resolve(response)
          )
      )

      return deferred.promise

    @saveSubscription = (subscription, currency) ->
      # If we are requesting to provision a new subscription, we need to create the subscription.
      unless subscription.id
        _self.createSubscription(subscription, currency)
      # Otherwise we need to create subscription event on the existing subscription.
      else
        _self.createSubscriptionEvent(subscription, currency)

    @fetchSubscription = (id, cart) ->
      deferred = $q.defer()
      MnoeOrganizations.get().then(
        (response) ->
          params = if cart then { 'subscription[cart_entry]': 'true' } else {}
          MnoeApiSvc.one('/organizations', response.organization.id).one('subscriptions', id).get(params).then(
            (response) ->
              deferred.resolve(response)
          )
      )
      return deferred.promise

    @getSubscriptions = (params = {}, cart = false) ->
      return _self.cartSubscriptionsPromise if cart && _self.cartSubscriptionsPromise?

      deferred = $q.defer()
      MnoeOrganizations.get().then(
        (response) ->
          subscriptionsApi(response.organization.id).getList(params).then(
            (response) ->
              deferred.resolve(response)
          )
      )
      _self.cartSubscriptionsPromise = deferred.promise if cart
      return deferred.promise

    @getSubscriptionEvents = (subscriptionId, sort, params = {}) ->
      params["order_by"] = sort
      deferred = $q.defer()
      MnoeOrganizations.get().then(
        (response) ->
          MnoeApiSvc.one('organizations', response.organization.id).one('subscriptions', subscriptionId).customGETLIST('subscription_events', params).then(
            (response) ->
              deferred.resolve(response)
          )
      )
      return deferred.promise

    @deleteCartSubscriptions = ->
      deferred = $q.defer()
      MnoeOrganizations.get().then(
        (response) ->
          MnoeApiSvc.one('organizations', response.organization.id).one('subscriptions').post('/cancel_cart_subscriptions').then(
            (response) ->
              deferred.resolve(response)
          )
      )

    @getQuote = (s, currency) ->
      MnoeOrganizations.get().then(
        (response) ->
          quoteParams = {product_id: s.product.id, product_pricing_id: s.product_pricing?.id, custom_data: s.custom_data, organization_id: response.organization.id, selected_currency: currency}
          MnoeApiSvc.one('organizations', response.organization.id).all('quotes').post(quote: quoteParams)
      )

    @submitCartSubscriptions = ->
      deferred = $q.defer()
      MnoeOrganizations.get().then(
        (response) ->
          MnoeApiSvc.one('organizations', response.organization.id).one('subscriptions').post('/submit_cart_subscriptions').then(
            (response) ->
              deferred.resolve(response)
          )
      )
      return deferred.promise

    @saveSubscriptionCart = (s, c) ->
      subscription_params = {
        currency: c, product_id: s.product.id, product_pricing_id: s.product_pricing?.id,
        max_licenses: s.max_licenses, edit_action: s.event_type, custom_data: s.custom_data, cart_entry: s.cart_entry
      }
      deferred = $q.defer()
      if s.id
        MnoeOrganizations.get().then(
          (response) ->
            subscription.patch({subscription: subscription_params}).then(
              (response) ->
                deferred.resolve(response)
            )
        )
      else
        MnoeOrganizations.get().then(
          (response) ->
            subscriptionsApi(response.organization.id).post({subscription: subscription_params}).then(
              (response) ->
                deferred.resolve(response)
            )
        )

      return deferred.promise

    @emptyCartSubscriptions = () ->
      _self.cartSubscriptionsPromise = null

    @refreshCartSubscriptions = ->
      _self.emptyCartSubscriptions()
      _self.getSubscriptions({ where: {subscription_status_in: 'staged' } })

    return
