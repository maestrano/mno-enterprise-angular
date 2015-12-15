angular.module 'mnoEnterpriseAngular'
  .controller 'LayoutController', (MnoeCurrentUser, MnoeOrganizations) ->
    'ngInject'

    layout = this

    console.log "in LayoutController"

    MnoeCurrentUser.get().then(
      (response) ->
        # Load the current organization if defined (url param, cookie or first)
        MnoeOrganizations.onAppInit(response)
    )

    return
