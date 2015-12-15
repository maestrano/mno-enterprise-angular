angular.module 'mnoEnterpriseAngular'
  .controller 'LayoutController', ($stateParams, MnoeCurrentUser, MnoeOrganizations) ->
    'ngInject'

    layout = this

    console.log "in LayoutController", $stateParams

    MnoeCurrentUser.get().then(
      (response) ->
        # Load the current organization if defined (url param, cookie or first)
        MnoeOrganizations.onAppInit(response, $stateParams.dhbRefId)
    )

    return
