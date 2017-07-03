# Service for managing the users.
angular.module 'mnoEnterpriseAngular'
  .service 'MnoeProvisioning', ($q, $log, MnoeApiSvc, MnoeOrganizations) ->
    _self = @

    subscriptionsApi = (id) -> MnoeApiSvc.one('/organizations', id).all('subscriptions')

    productsApi = MnoeApiSvc.oneUrl('/products')
    productsPromise = null
    productsResponse = null

    currentProduct = null
    pricingPlan = null
    customData = {}

    @getProducts = () ->
      return productsPromise if productsPromise?
      productsPromise = productsApi.get().then(
        (response) ->
          productsResponse = response.plain()
          response
      )

    @findProduct = (nid) ->
      _.find(productsResponse.products, (a) -> a.nid == nid)

    @setCurrentProduct = (p) ->
      currentProduct = p

    @getCurrentProduct = () ->
      currentProduct

    @setPricingPlan = (p) ->
      pricingPlan = p

    @getPricingPlan = ->
      pricingPlan

    @setCustomData = (data) ->
      customData = data

    @getCustomData = () ->
      customData

    @createSubscription = () ->
      subscriptionsApi().post({subscription: {pricing_id: pricingPlan.id, custom_data: customData}}).then(
        (response) ->
          console.log("### DEBUG post response", response)
          response
      )

    @saveSubscription = (subscription) ->
      subscriptions.put({subscription: {pricing_id: pricingPlan.id, custom_data: customData}}).then(
        (response) ->
          console.log("### DEBUG put response", response)
          response
      )

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
