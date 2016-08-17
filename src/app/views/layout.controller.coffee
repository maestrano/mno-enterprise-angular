angular.module 'mnoEnterpriseAngular'
  .controller 'LayoutController', ($stateParams, $state, $q, MnoeCurrentUser, MnoeOrganizations, MnoeMarketplace) ->
    'ngInject'

    layout = this

    # Hide the layout
    layout.isLoggedIn = false

    # App initialization
    userPromise = MnoeCurrentUser.get()

    # Load the current organization if defined (url param, cookie or first)
    organizationPromise = MnoeOrganizations.getCurrentId($stateParams.dhbRefId)

    $q.all([userPromise, organizationPromise]).then(
      ->
        # Display the layout
        layout.isLoggedIn = true

        # Pre-load the market place
        MnoeMarketplace.getApps()

        # Remove param from url
        $state.go('.', {dhbRefId: undefined})
    )

    return
