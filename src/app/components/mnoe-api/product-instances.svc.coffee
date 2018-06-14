angular.module 'mnoEnterpriseAngular'
  .service 'MnoeProductInstances', ($q, MnoeApiSvc, MnoeOrganizations, MnoLocalStorage, MnoeCurrentUser, LOCALSTORAGE) ->
    _self = @

    # Store selected organization app instances
    @productInstances = []

    productInstancesPromise = null
    @getProductInstances = ->
      # Note: Temporarily commented out product instance cache till actual
      #       connec implementation from APPINT-1238 for sync status is done.
      # return productInstancesPromise if productInstancesPromise?

      deferred = $q.defer()

      # If app instances are stored return it and refresh the cache asynchronously
      cache = MnoLocalStorage.getObject(MnoeCurrentUser.user.id + "_" + LOCALSTORAGE.productInstancesKey)
      if cache?
        # Refresh the cache content asynchronously
        fetchProductInstances()
        # Append response array to service array
        _self.productInstances = cache
        # Return the promised cache
        deferred.resolve(cache)
      else
        # If the cache is empty return the call promise
        fetchProductInstances().then((response) -> deferred.resolve(response))

      return productInstancesPromise = deferred.promise

    @refreshProductInstances = ->
      productInstancesPromise = null
      _self.clearCache()
      _self.emptyProductInstances()
      fetchProductInstances()

    # Retrieve app instances from the backend
    fetchProductInstances = ->
      # Workaround as the API is not standard (return a hash map not an array)
      # (Prefix operation by '/' to avoid data extraction)
      # TODO: Standard API
      defer = $q.defer()
      MnoeOrganizations.get().then(
        ->
          _self.productInstancesPromise = MnoeApiSvc.one('organizations', MnoeOrganizations.selectedId).one('/product_instances').get().then(
            (response) ->
              response = response.plain()
              # Save the app instances in the local storage
              productInstances = processProductInstances(response)
              MnoLocalStorage.setObject(MnoeCurrentUser.user.id + "_" + LOCALSTORAGE.productInstancesKey, productInstances)
              # Process the response
              defer.resolve(productInstances)
          )
      )
      return defer.promise

    # Process app instances to append them to the public variable
    processProductInstances = (response) ->
      # Empty app instances service array
      _self.productInstances.length = 0
      # Transform hash map to array
      arr = _.values(response.product_instances)
      # Append response array to service array
      Array.prototype.push.apply(_self.productInstances, arr)
      return _self.productInstances

    # Note: oAuth setup is not available in Product Instances. This needs to be
    #       added when available
    # Path to connect this product instance and redirect to the current page
    @oAuthConnectPath = (instance, extra_params = '') ->

    @terminate = (id) ->
      MnoeApiSvc.one('product_instances', id).remove().then(
        ->
          # Remove the corresponding app from the list
          _.remove(_self.productInstances, {id: id})

          # Update the local storage cache
          MnoLocalStorage.setObject(MnoeCurrentUser.user.id + "_" + LOCALSTORAGE.productInstancesKey, _self.productInstances)
      )

    @emptyProductInstances = () ->
      productInstancesPromise = null
      @productInstances.length = 0

    @clearCache = () ->
      MnoLocalStorage.removeItem(MnoeCurrentUser.user.id + "_" + LOCALSTORAGE.productInstancesKey)

    @installStatus = (productInstance) ->
      if productInstance.app_nid != 'office-365' && productInstance.stack == 'connector' && !productInstance.oauth_keys_valid
        "INSTALLED_CONNECT"
      else
        "INSTALLED_LAUNCH"

    return @
