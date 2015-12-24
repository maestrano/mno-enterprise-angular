angular.module 'mnoEnterpriseAngular'
  .controller 'LayoutController', ($stateParams, $window, $location, MnoeCurrentUser, MnoeOrganizations, MnoeMarketplace) ->
    'ngInject'

    layout = this

    # App initialization
    MnoeCurrentUser.get().then(
      (response) ->
        if !response.logged_in
          $window.location.href = '/'

        # Load the current organization if defined (url param, cookie or first)
        MnoeOrganizations.getCurrentId(response, $stateParams.dhbRefId).then(
          () ->
            # Pre-load the market place
            MnoeMarketplace.getApps()
        )

        # Remove param from url
        $location.search('dhbRefId', null)
    )

    return
