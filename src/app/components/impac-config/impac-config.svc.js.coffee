angular.module 'mnoEnterpriseAngular'
  .service('ImpacConfigSvc' , ($log, $q, MnoeCurrentUser, MnoeOrganizations) ->

    @getUserData = ->
      MnoeCurrentUser.get()

    @getOrganizations = ->
      deferred = $q.defer()

      MnoeCurrentUser.get().then(
        (response) ->
          currentOrgId = parseInt(MnoeOrganizations.selectedId)
          userOrgs = response.organizations

          if userOrgs && currentOrgId
            deferred.resolve({organizations: userOrgs, currentOrgId: currentOrgId})
          else
            $log.error(err = {msg: "Unable to retrieve user organizations"})
            deferred.reject(err)

          return deferred.promise
      )

    return @
  )
