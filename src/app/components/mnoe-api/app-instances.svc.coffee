angular.module 'mnoEnterpriseAngular'
  .service 'MnoeAppInstances', ($q, MnoeApiSvc, MnoeOrganizations, MnoLocalStorage, MnoeCurrentUser, LOCALSTORAGE) ->
    _self = @

    # Store selected organization app instances
    @appInstances = []

    @getAppInstances = ->
      # If app instances are stored return it
      cache = MnoLocalStorage.getObject(MnoeCurrentUser.user.id + "_" + LOCALSTORAGE.appInstancesKey)
      if cache?
        # Process the cached response
        processAppInstances(cache)
        # Return the promised cache
        return $q.resolve(cache)

      # If the cache is empty return the promise call
      return fetchAppInstances()

    @refreshAppInstances = ->
      _self.clearCache()
      _self.emptyAppInstances()
      fetchAppInstances()

    # Retrieve app instances from the backend
    fetchAppInstances = ->
      # Workaround as the API is not standard (return a hash map not an array)
      # (Prefix operation by '/' to avoid data extraction)
      # TODO: Standard API
      defer = $q.defer()
      MnoeOrganizations.get(MnoeOrganizations.selectedId).then(
        ->
          _self.appInstancesPromise = MnoeApiSvc.one('organizations', MnoeOrganizations.selectedId).one('/app_instances').get().then(
            (response) ->
              response = response.plain()
              # Save the response in the local storage
              MnoLocalStorage.setObject(MnoeCurrentUser.user.id + "_" + LOCALSTORAGE.appInstancesKey, response)
              # Process the cached response
              processAppInstances(response)
              # Process the response
              defer.resolve(response)
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
      @appInstances.length = 0

    @clearCache = () ->
      MnoLocalStorage.removeItem(MnoeCurrentUser.user.id + "_" + LOCALSTORAGE.appInstancesKey)

    @installStatus = (appInstance) ->
      if appInstance.app_nid != 'office-365' && appInstance.stack == 'connector' && !appInstance.oauth_keys_valid
        "INSTALLED_CONNECT"
      else
        "INSTALLED_LAUNCH"

    return @
