angular.module 'mnoEnterpriseAngular'
  .controller 'PublicController', ($scope, $rootScope, $stateParams, $state, $q, URI, MnoeCurrentUser, MnoeOrganizations, MnoeConfig) ->
    'ngInject'

    layout = @
    layout.links = URI

    $window.location = URI.login unless MnoeConfig.arePublicPagesEnabled()

    MnoeCurrentUser.get().then(
      (response) ->
        if response.logged_in
          $state.go('home.impac')
    )

    return
