angular.module 'mnoEnterpriseAngular'
  .controller 'PublicController', ($scope, $rootScope, $stateParams, $state, $q, URI, MnoeCurrentUser, MnoeOrganizations, MnoeConfig) ->
    'ngInject'

    layout = @

    layout.isRegistrationEnabled = MnoeConfig.isRegistrationEnabled()

    $state.go('login') unless MnoeConfig.arePublicApplicationsEnabled()

    MnoeCurrentUser.get().then(
      (response) ->
        $state.go('home.impac') if response.logged_in
    )

    return
