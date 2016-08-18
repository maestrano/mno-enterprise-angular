angular.module 'mnoEnterpriseAngular'
  .service('ImpacConfigSvc' , ($log, $q, MnoeCurrentUser, MnoeOrganizations) ->

    @getUserData = ->
      MnoeCurrentUser.get()

    @getOrganizations = ->
      userOrgs = MnoeCurrentUser.get().then(
        ->
          userOrgs = MnoeCurrentUser.user.organizations

          if !userOrgs
            $log.error(err = {msg: "Unable to retrieve user organizations"})
            return $q.reject(err)

          return userOrgs
      )

      currentOrgId = MnoeOrganizations.get().then(
        ->
          currentOrgId = parseInt(MnoeOrganizations.selectedId)

          if !currentOrgId
            $log.error(err = {msg: "Unable to retrieve current organization"})
            return $q.reject(err)

          return currentOrgId
      )

      $q.all([userOrgs, currentOrgId]).then(
        (responses) ->
          return {organizations: responses[0], currentOrgId: responses[1]}
      )

    return @
  )
