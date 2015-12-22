angular.module 'mnoEnterpriseAngular'
  .service 'MnoeTeams', (MnoeApiSvc, MnoeOrganizations) ->
    _self = @

    # Store teams
    @teams = null

    @getTeams = ->
      MnoeApiSvc.one('organizations', MnoeOrganizations.selectedId).one('teams').getList().then(
        (response) ->
          _self.teams = response
          response
      )

    return @
