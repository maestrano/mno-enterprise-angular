# Service for managing the users.
angular.module 'mnoEnterpriseAngular'
  .service 'MnoeOrganizations', ($state, $cookies, $log, $q, MnoeApiSvc, MnoeCurrentUser) ->
    _self = @

    organizationsApi = MnoeApiSvc.all('organizations')

    # Store the selected entity id
    # Mostly used to refresh the UI befor the selected entity is requested
    @selectedId = null

    @getSelectedId = ->
      _self.selectedId

    # Store the selected entity
    @selected = null

    # Store selected organization app instances
    @appInstances = []

    @list = () ->
      organizationsApi.getList().then(
        (response) ->
          _self.list = response
          response
      )

    @get = (id) ->
      _self.selectedId = id

      # Get the selected organization
      organizationPromise = MnoeApiSvc.one('organizations', id).get().then(
        (response) ->
          # Save the organization
          _self.selected = response
          $cookies.put('dhb_ref_id', response.id)
          $log.debug('selected organization', response)
          response
      )

      # # Get organization app instances
      # appInstancesPromise = _self.getAppInstances().then(
      #   (response) ->
      #     $log.debug('app_instances', response)
      #     # Append the response array in service array
      #
      # )
      return

    @getAppInstances = () ->
      # Empty app instances service array
      _self.appInstances.length = 0

      # Workaround as the API is not standard (return a hash map not an array)
      # (Prefix operation by '/' to avoid data extraction)
      # TODO: Standard API
      MnoeApiSvc.one('organizations', _self.selectedId).one('/app_instances').get().then(
        (response) ->
          # Transform hash map to array
          response = _.values(response.app_instances)
          #Append response array to service array
          Array.prototype.push.apply(_self.appInstances, response)
          return _self.appInstances
      )

    @create = (organization) ->
      organizationsApi.post(organization)

    @update = (organization) ->
      organization.put()

    # Load the current organization if defined (url, cookie or first)
    @getCurrentId = (user = null, dhbRefId = null) ->
      deferred = $q.defer()

      $log.debug "in MnoeOrganizations.getCurrentId"

      # Return the already selected id
      if _self.selectedId
        $log.debug "MnoeOrganizations.getCurrentId: selectedId", _self.selectedId
        deferred.resolve(_self.selectedId)

      # Attempt to load organization from param
      else if dhbRefId
        _self.get(dhbRefId)
        $log.debug "MnoeOrganizations.getCurrentId: dhbRefId", _self.selectedId
        deferred.resolve(dhbRefId)

      # Attempt to load last organization from cookie
      else if (val = $cookies.get('dhb_ref_id'))
        _self.get(val)
        $log.debug "MnoeOrganizations.getCurrentId: cookie", _self.selectedId
        deferred.resolve(val)

      # Load first organization from user
      else
        # If the app is initializing, return the correct organization id
        organization = user.organizations[0]
        _self.get(organization.id)
        $log.debug "MnoeOrganizations.getCurrentId: first", _self.selectedId
        deferred.resolve(organization.id)

      return deferred.promise

    return @
