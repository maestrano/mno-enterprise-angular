# Service to update the current user

# We're not using angular-devise as the update functionality hasn't been
# merged yet.
# As we're using Devise + Her, we have custom routes to update the current user
# It then makes more sense to have an extra service rather than have customised
# fork of the upstream library

# MnoeCurrentUser.update(name: 'John')
# => PUT /mnoe/jpi/v1/current_user/update

# MnoeCurrentUser.updatePassword1({current_password: 'Password1', password: 'Password2', password_confirmation: 'Password2'})
# => PUT /mnoe/jpi/v1/current_user/update_password

angular.module 'mnoEnterpriseAngular'
  .service 'MnoeCurrentUser', (MnoeApiSvc, $window, $state, $q, $timeout, $rootScope, URI, Auth, MnoeConfig) ->
    _self = @

    # Store the current_user promise
    # Only one call will be executed even if there is multiple callers at the same time
    userPromise = null

    # Save the current user in variable to be able to reference it directly
    @user = {}

    # Redirect if user is already logged in
    @skipIfLoggedIn = ->
      Auth.currentUser().then(
        (response) ->
          $timeout( -> $state.go('home.impac') )
          $q.reject()
        ->
          $q.resolve()
      )

    @loginRequired = ->
      Auth.currentUser().catch(
        ->
          $timeout( -> $state.go('login') )
          $q.reject()
      )

    # Get the current user
    @get = (opts = {})->
      return userPromise if userPromise?

      userPromise = MnoeApiSvc.one('current_user').get().then(
        (response) ->
          response = response.plain()

          if ! (opts.skip_login_check || response.logged_in)
            $state.go('login')

          angular.copy(response, _self.user)
          response
      )

    @refresh = ->
      userPromise = null
      _self.get()

    # Update the current user infos
    @update = (user) ->
      MnoeApiSvc.all('current_user').doPUT({user: user}).then(
        (response) ->
          angular.copy(response, _self.user)
          response
      )

    @registerDeveloper = () ->
      MnoeApiSvc.all('/current_user').doPUT({},'/register_developer').then(
        (response) ->
          response.current_user
      )

    # Update user password
    @updatePassword = (passwordData) ->
      MnoeApiSvc.all('/current_user').doPUT({user: passwordData}, 'update_password')

    return @
