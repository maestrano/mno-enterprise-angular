angular.module 'mnoEnterpriseAngular'
  .controller 'LayoutController', ($stateParams, $location, MnoeCurrentUser, MnoeOrganizations) ->
    'ngInject'

    layout = this

    #console.log "in LayoutController", $stateParams

    # App initialization
    MnoeCurrentUser.get().then(
      (response) ->
        # Load the current organization if defined (url param, cookie or first)
        MnoeOrganizations.getCurrentId(response, $stateParams.dhbRefId).then(
          (response) ->
            console.log "in LayoutController", response
        )

        # Remove param from url
        $location.search('dhbRefId', null)
    )

    return
