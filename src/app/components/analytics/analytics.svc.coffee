angular.module 'mnoEnterpriseAngular'
  .service 'AnalyticsSvc', (MnoeCurrentUser, INTERCOM_ID, $window) ->

    @bootIntercom = (userData) ->
      $window.Intercom('boot', userData ) if $window.Intercom

    @updateIntercom = (userData) ->
      $window.Intercom('update', userData ) if $window.Intercom

    @shutdownIntercom = ->
      Intercom('shutdown') if $window.Intercom

    @getUserData = ->
      MnoeCurrentUser.get().then(
        (response)->
          userData = {
            app_id: INTERCOM_ID,
            name: response.name,
            surname: response.surname,
            company: response.company,
            email: response.email,
            created_at: response.created_at
          }
          
          return userData
      )

    return @
