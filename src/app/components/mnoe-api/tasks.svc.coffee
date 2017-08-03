# Service for managing the users.
angular.module 'mnoEnterpriseAngular'
  .service 'MnoeTasks', ($log, $q, toastr, MnoeApiSvc, MnoeOrganizations) ->
    _self = @

    @get = (params = {})->
      MnoeOrganizations.get().then(->
        MnoeApiSvc
          .one('organizations', MnoeOrganizations.getSelectedId())
          .getList('tasks', params)
          .then(
            (response)-> response.plain()
        )
      )

    @update = (id, params = {})->
      MnoeOrganizations.get().then(->
        MnoeApiSvc
          .one('organizations', MnoeOrganizations.getSelectedId())
          .one('tasks', id)
          .patch(params)
          .then(
            (response)-> response.plain().task
        )
      )

    return @
