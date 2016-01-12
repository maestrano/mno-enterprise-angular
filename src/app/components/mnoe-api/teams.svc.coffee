angular.module 'mnoEnterpriseAngular'
  .service 'MnoeTeams', (MnoeApiSvc, MnoeOrganizations) ->
    _self = @

    # Store teams
    @teams = null

    @getTeams = ->
      MnoeApiSvc.one('organizations', MnoeOrganizations.selectedId).one('teams').getList().then(
        (response) ->
          _self.teams = response.plain()
          _self.teams
      )

    @addTeam = (team) ->
      payload = { team: team }
      MnoeApiSvc.one('organizations', MnoeOrganizations.selectedId).post('teams', payload).then(
        (response) ->
          team = response.plain()
          _self.teams.push(team)
          team
      )

    @deleteTeam = (teamId) ->
      MnoeApiSvc.one('teams', teamId).remove()

    @addUsers = (teamId, users) ->
      payload = { team: { users: users } }
      MnoeApiSvc.one('teams', teamId).customPUT(payload, '/add_users').then(
        (response) ->
          response = response.plain()
          # return the users
          response.team.users
      )

    # TODO: Refactor API method to simplify it
    @removeUser = (teamId, user) ->
      payload = { team: { users: [user] } }
      MnoeApiSvc.one('teams', teamId).customPUT(payload, '/remove_users').then(
        (response) ->
          response = response.plain()
          # return the users
          response.team.users
      )

    return @
