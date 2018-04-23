angular.module 'mnoEnterpriseAngular'
  .controller 'PublicController', ($scope, $rootScope, $stateParams, $state, $q, $window, URI, MnoeCurrentUser, MnoeOrganizations, MnoeConfig) ->
    'ngInject'

    layout = @
    layout.links = URI
    layout.isLoading = true
    layout.isRegistrationEnabled = MnoeConfig.isRegistrationEnabled()

    $window.location = URI.login unless MnoeConfig.arePublicApplicationsEnabled()

    MnoeCurrentUser.get().then(
      (response) ->
        $state.go('home.impac') if response.logged_in
    ).finally(-> layout.isLoading = false)

    return
