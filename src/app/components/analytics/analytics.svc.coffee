angular.module 'mnoEnterpriseAngular'
  .service 'AnalyticsSvc', (MnoeCurrentUser, INTERCOM_ID, $window) ->

    # Will push user data to intercom and boot it
    @init = (userData) ->
      if $window.Intercom
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
            $window.Intercom('boot', userData)
        )

    # Will update in every page change so intercom knows we're still active and load new messages
    @update = () ->
      $window.Intercom('update') if $window.Intercom

    # When user logs out, call to end the Intercom session and clear the cookie.
    @logOut = ->
      $window.Intercom('shutdown') if $window.Intercom

    return @
