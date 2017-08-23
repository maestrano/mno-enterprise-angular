angular.module 'mnoEnterpriseAngular'
  .service 'MnoeUserAccessRequests', (MnoeApiSvc) ->

    @create = (user_access_request) ->
      MnoeApiSvc.all('user_access_requests').post(user_access_request)

    @last_access_request = () ->
      MnoeApiSvc.all('user_access_requests').doGET('/last_access_request').then(
        (response) ->
          response.user_access_request if response
      )

    @list = () ->
      MnoeApiSvc.all('user_access_requests').getList().then(
        (response) ->
          response.plain()
      )


    @deny = (id) ->
      MnoeApiSvc.one('user_access_requests', id).doPUT({}, '/deny').then(
        (response) ->
          response.user_access_request
      )

    @approve = (id) ->
      MnoeApiSvc.one('user_access_requests', id).doPUT({}, '/approve').then(
        (response) ->
          response.user_access_request
      )

    @revoke = (id) ->
      MnoeApiSvc.one('user_access_requests', id).doPUT({}, '/revoke').then(
        (response) ->
          response.user_access_request
      )

    return @
