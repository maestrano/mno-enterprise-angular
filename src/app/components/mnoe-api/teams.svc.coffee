angular.module 'mnoEnterpriseAngular'
  .service 'MnoeTeams', (MnoeApiSvc, MnoeOrganizations) ->
    _self = @

    # Store teams
    @teams = []

    teamsPromise = null

    @getTeams = (force = false) ->
      return teamsPromise if teamsPromise != null && !force

      teamsPromise = MnoeApiSvc.one('organizations', MnoeOrganizations.selectedId).one('teams').getList().then(
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

    @updateTeamName = (team) ->
      payload = { team: _.pick(team, "name") }
      MnoeApiSvc.one('teams', team.id).patch(payload).then(
        (response) ->
          newTeam = response.plain()
          listTeam = _.find(_self.teams, {id: team.id})
          angular.copy(newTeam, listTeam)
          response
      )

    @updateTeamAppInstances = (team, appInstances) ->
      payload = { team: {app_instances: appInstances} }
      MnoeApiSvc.one('teams', team.id).patch(payload).then(
        (response) ->
          newTeam = response.plain()
          listTeam = _.find(_self.teams, {id: team.id})
          angular.copy(newTeam, listTeam)
          response
      )

    @deleteTeam = (teamId) ->
      MnoeApiSvc.one('teams', teamId).remove().then(
        (response) ->
          _.remove(_self.teams, {id: teamId})
          response
      )

    @addUsers = (teamId, users) ->
      payload = { team: { users: users } }
      MnoeApiSvc.one('teams', teamId).customPUT(payload, '/add_users').then(
        (response) ->
          response = response.plain()
          # Update the team's users in the frontend
          _.find(_self.teams, {id: teamId}).users.push users...
          # return the users
          response.team.users
      )

    # TODO: Refactor API method to simplify it
    @removeUser = (teamId, user) ->
      payload = { team: { users: [user] } }
      MnoeApiSvc.one('teams', teamId).customPUT(payload, '/remove_users').then(
        (response) ->
          response = response.plain()
          # Update the team's users in the frontend
          _.find(_self.teams, {id: teamId}).users = response.team.users
          # return the users
          response.team.users
      )

    @updateTeamMemberRole = (member) ->
      _self.teams.forEach (team) ->
        team_member = _.find(team.users, {email: member.email})
        team_member.role = member.role if team_member

    return @
