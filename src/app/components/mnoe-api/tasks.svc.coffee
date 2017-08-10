# Service for managing the users.
angular.module 'mnoEnterpriseAngular'
  .service 'MnoeTasks', (MnoeFullApiSvc, MnoeOrganizations) ->
    @get = (params = {})->
      MnoeOrganizations.get().then(->
        MnoeFullApiSvc
          .one('organizations', MnoeOrganizations.getSelectedId())
          .getList('tasks', params)
      )

    @getRecipients = ->
      MnoeFullApiSvc
        .all('orga_relations')
        .getList()
        .then(
          (response)-> response.data.plain()
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

    @create = (params = {})->
      MnoeOrganizations.get().then(->
        MnoeFullApiSvc
          .one('organizations', MnoeOrganizations.getSelectedId())
          .all('tasks')
          .post(params)
          .then(
            (response)-> response.data.plain()
        )
      )

    return @
