angular.module 'mnoEnterpriseAngular'
  .service 'MnoeUserAccessRequests', (MnoeApiSvc) ->

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


    return @
