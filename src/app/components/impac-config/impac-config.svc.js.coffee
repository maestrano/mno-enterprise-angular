angular.module 'mnoEnterpriseAngular'
  .service('ImpacConfigSvc' , ($log, $q, MnoeCurrentUser, MnoeOrganizations) ->

    @getUserData = ->
      MnoeCurrentUser.get()

    @getOrganizations = ->
      userOrgsPromise = MnoeCurrentUser.get().then(
        ->
          userOrgs = MnoeCurrentUser.user.organizations

          if !userOrgs
            $log.error(err = {msg: "Unable to retrieve user organizations"})
            return $q.reject(err)

          return userOrgs
      )

      currentOrgPromise = MnoeOrganizations.get(MnoeOrganizations.selectedId).then(
        ->
          currentOrgId = parseInt(MnoeOrganizations.selectedId)
          currentOrgMembers = MnoeOrganizations.selected.organization.members

          if !currentOrgId
            $log.error(err = {msg: "Unable to retrieve current organization"})
            return $q.reject(err)

          return { currentOrgId: currentOrgId, currentOrgMembers: currentOrgMembers }
      )

      $q.all([userOrgsPromise, currentOrgPromise]).then(
        (responses) ->
          return {organizations: responses[0], currentOrgId: responses[1].currentOrgId, currentOrgMembers: responses[1].currentOrgMembers }
      )

    return @
  )
