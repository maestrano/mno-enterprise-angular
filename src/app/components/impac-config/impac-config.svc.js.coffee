angular.module 'mnoEnterpriseAngular'
  .service('ImpacConfigSvc' , ($log, $q, MnoeCurrentUser, MnoeOrganizations) ->

    _self = @

    @config =
      overrideOrgs: (orgs) -> orgs

    @configure = (overrideOrgsFunction) ->
      angular.merge(_self.config, { overrideOrgs: overrideOrgsFunction })

    @getUserData = ->
      MnoeCurrentUser.get()

    @getOrganizations = ->
      userOrgsPromise = MnoeCurrentUser.get().then(
        ->
          userOrgs = MnoeCurrentUser.user.organizations

          if !userOrgs
            $log.error(err = {msg: "Unable to retrieve user organizations"})
            return $q.reject(err)

          return _self.config.overrideOrgs(userOrgs)
      )

      currentOrgIdPromise = MnoeOrganizations.get(MnoeOrganizations.selectedId).then(
        ->
          currentOrgId = parseInt(MnoeOrganizations.selectedId)

          if !currentOrgId
            $log.error(err = {msg: "Unable to retrieve current organization"})
            return $q.reject(err)

          return currentOrgId
      )

      $q.all([userOrgsPromise, currentOrgIdPromise]).then(
        (responses) ->
          return { organizations: responses[0], currentOrgId: responses[1] }
      )

    return @
  )
