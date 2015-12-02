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
  .service 'MnoeCurrentUser', (MnoeApiSvc) ->
    _self = @

    @user = null

    # Get the current user
    # Should be called while initialising the app
    @get = ->
      MnoeApiSvc.one('current_user').get().then(
        (response) ->
          _self.user = response
          response
      )

    # TODO: update current @user
    # _self.user.put()
    @update = (data) ->
      currentUserApi.doPUT({user: data}, 'update')

    # TODO: update current @user
    @updatePassword = (passwordData) ->
      currentUserApi.doPUT({user: passwordData}, 'update_password')

    return @
