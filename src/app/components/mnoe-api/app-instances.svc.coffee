angular.module 'mnoEnterpriseAngular'
  .service 'MnoeAppInstances', ($q, MnoeApiSvc, MnoeOrganizations, MnoLocalStorage, MnoeCurrentUser, LOCALSTORAGE) ->
    _self = @

    # Store selected organization app instances
    @appInstances = []

    appInstancesPromise = null
    @getAppInstances = ->
      return appInstancesPromise if appInstancesPromise?

      deferred = $q.defer()

      # If app instances are stored return it and refresh the cache asynchronously
      cache = MnoLocalStorage.getObject(MnoeCurrentUser.user.id + "_" + LOCALSTORAGE.appInstancesKey)
      if cache?
        # Refresh the cache content asynchronously
        fetchAppInstances()
        # Append response array to service array
        _self.appInstances = cache
        # Return the promised cache
        deferred.resolve(cache)
      else
        # If the cache is empty return the call promise
        fetchAppInstances().then((response) -> deferred.resolve(response))

      return appInstancesPromise = deferred.promise

    @refreshAppInstances = ->
      appInstancesPromise = null
      _self.clearCache()
      _self.emptyAppInstances()
      fetchAppInstances()

    # Retrieve app instances from the backend
    fetchAppInstances = ->
      # Workaround as the API is not standard (return a hash map not an array)
      # (Prefix operation by '/' to avoid data extraction)
      # TODO: Standard API
      defer = $q.defer()
      MnoeOrganizations.get().then(
        ->
          _self.appInstancesPromise = MnoeApiSvc.one('organizations', MnoeOrganizations.selectedId).one('/app_instances').get().then(
            (response) ->
              response = response.plain()
              # Save the app instances in the local storage
              appInstances = processAppInstances(response)
              MnoLocalStorage.setObject(MnoeCurrentUser.user.id + "_" + LOCALSTORAGE.appInstancesKey, appInstances)
              # Process the response
              defer.resolve(appInstances)
          )
      )
      return defer.promise

    # Process app instances to append them to the public variable
    processAppInstances = (response) ->
      # Empty app instances service array
      _self.appInstances.length = 0
      # Transform hash map to array
      arr = _.values(response.app_instances)
      # Append response array to service array
      Array.prototype.push.apply(_self.appInstances, arr)
      return _self.appInstances

    # Path to connect this app instance and redirect to the current page
    @oAuthConnectPath = (instance, extra_params = '') ->
      _self.clearCache()
      _self.emptyAppInstances()
      redirect = window.encodeURIComponent("#{location.pathname}#{location.hash}")
      "/mnoe/webhook/oauth/#{instance.uid}/authorize?redirect_path=#{redirect}&#{extra_params}"

    @terminate = (id) ->
      MnoeApiSvc.one('app_instances', id).remove().then(
        ->
          # Remove the corresponding app from the list
          _.remove(_self.appInstances, {id: id})

          # Update the local storage cache
          MnoLocalStorage.setObject(MnoeCurrentUser.user.id + "_" + LOCALSTORAGE.appInstancesKey, _self.appInstances)
      )

    @emptyAppInstances = () ->
      appInstancesPromise = null
      @appInstances.length = 0

    @clearCache = () ->
      MnoLocalStorage.removeItem(MnoeCurrentUser.user.id + "_" + LOCALSTORAGE.appInstancesKey)

    @installStatus = (appInstance) ->
      if appInstance.app_nid != 'office-365' && appInstance.stack == 'connector' && !appInstance.oauth_keys_valid
        "INSTALLED_CONNECT"
      else
        "INSTALLED_LAUNCH"

    @getAppInstanceSync = ->
      MnoeOrganizations.get().then(
        -> MnoeApiSvc.one('organizations', MnoeOrganizations.selectedId).one('/app_instances_sync').get()
      )

    return @
