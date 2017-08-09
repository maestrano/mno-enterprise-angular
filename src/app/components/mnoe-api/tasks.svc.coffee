# Service for managing the users.
angular.module 'mnoEnterpriseAngular'
  .service 'MnoeTasks', (MnoeFullApiSvc, MnoeOrganizations) ->
    _self = @

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
          # TODO: XDE -> XLO: Hack to be able to show user first nam and last name. Please correct mno-ui-element to accept a recipient renderer or just accept an hash {id, name}
          (response)-> _.map(response.data.plain(), (orgaRel) -> {id: orgaRel.id, user: {name: orgaRel.user.name + " " + orgaRel.user.surname}})
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
