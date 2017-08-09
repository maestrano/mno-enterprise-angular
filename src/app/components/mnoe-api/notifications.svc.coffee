# Service for managing the users.
angular.module 'mnoEnterpriseAngular'
  .service 'MnoeNotifications', (MnoeFullApiSvc, MnoeOrganizations) ->
    _self = @

    @get = (params = {})->
      MnoeOrganizations.get().then(->
        MnoeFullApiSvc
          .one('organizations', MnoeOrganizations.getSelectedId())
          .getList('notifications', params)
      )

    @notified = (params)->
      MnoeOrganizations.get().then(->
        MnoeFullApiSvc
          .one('organizations', MnoeOrganizations.getSelectedId())
          .one('notifications')
          .post('/notified', params)
      )

    return @
