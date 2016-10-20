angular.module 'mnoEnterpriseAngular'
  .service 'MnoeAppInstances', ($q, MnoeApiSvc, MnoeOrganizations, MnoLocalStorage, MnoeCurrentUser, LOCALSTORAGE) ->
    _self = @

    # Store selected organization app instances
    @appInstances = []

    @getAppInstances = ->
      # Fetch up to date app instances
      promise = fetchAppInstances()

      # If app instances are stored return it
      cache = MnoLocalStorage.getObject(MnoeCurrentUser.user.id + "_" + LOCALSTORAGE.appInstancesKey)
      if cache?
        # Process the cache
        processAppInstances(cache)
        # Return the promised cache
        return $q.resolve(cache)

      # If the cache is empty return the call promise
      return promise

    # Retrieve app instances from the backend
    fetchAppInstances = ->
      # Workaround as the API is not standard (return a hash map not an array)
      # (Prefix operation by '/' to avoid data extraction)
      # TODO: Standard API
      MnoeApiSvc.one('organizations', MnoeOrganizations.selectedId).one('/app_instances').get().then(
        (response) ->
          # Save the response in the local storage
          MnoLocalStorage.setObject(MnoeCurrentUser.user.id + "_" + LOCALSTORAGE.appInstancesKey, response.app_instances)
          # Process the response
          processAppInstances(response.app_instances)
      )

    # Process app instances to append them to the public variable
    processAppInstances = (appInstances) ->
      # Empty app instances service array
      _self.appInstances.length = 0
      # Transform hash map to array
      response = _.values(appInstances)
      #Append response array to service array
      Array.prototype.push.apply(_self.appInstances, response)
      return _self.appInstances

    @terminate = (id) ->
      MnoeApiSvc.one('app_instances', id).remove().then(
        (response) ->
          # Remove the corresponding app from the list
          _.remove(_self.appInstances, {id: id})

          # Update the local storage cache
          MnoLocalStorage.setObject(MnoeCurrentUser.user.id + "_" + LOCALSTORAGE.appInstancesKey, _self.appInstances)
      )

    @emptyAppInstances = () ->
      @appInstances.length = 0

    @clearCache = () ->
      MnoLocalStorage.removeItem(MnoeCurrentUser.user.id + "_" + LOCALSTORAGE.appInstancesKey)

    return @
