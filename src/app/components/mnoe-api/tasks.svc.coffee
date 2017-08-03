# Service for managing the users.
angular.module 'mnoEnterpriseAngular'
  .service 'MnoeTasks', ($log, $q, toastr, MnoeFullApiSvc, MnoeOrganizations) ->
    _self = @

    @get = (params = {})->
      MnoeOrganizations.get().then(->
        MnoeFullApiSvc
          .one('organizations', MnoeOrganizations.getSelectedId())
          .getList('tasks', params)
      )

    @update = (id, params = {})->
      MnoeOrganizations.get().then(->
        MnoeFullApiSvc
          .one('organizations', MnoeOrganizations.getSelectedId())
          .one('tasks', id)
          .patch(params)
          .then(
            (response)-> response.data.plain().task
        )
      )

    return @
