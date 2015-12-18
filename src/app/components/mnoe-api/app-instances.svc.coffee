angular.module 'mnoEnterpriseAngular'
  .service 'MnoeAppInstances', (MnoeApiSvc, MnoeOrganizations) ->
    _self = @

    # Store selected organization app instances
    @appInstances = []

    @getAppInstances = ->
      # Empty app instances service array
      _self.appInstances.length = 0

      # Workaround as the API is not standard (return a hash map not an array)
      # (Prefix operation by '/' to avoid data extraction)
      # TODO: Standard API
      MnoeApiSvc.one('organizations', MnoeOrganizations.selectedId).one('/app_instances').get().then(
        (response) ->
          # Transform hash map to array
          response = _.values(response.app_instances)
          #Append response array to service array
          Array.prototype.push.apply(_self.appInstances, response)
          return _self.appInstances
      )

    @terminate = (id) ->
      MnoeApiSvc.one('app_instances', id).remove()

    return @
