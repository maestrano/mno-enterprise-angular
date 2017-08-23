angular.module 'mnoEnterpriseAngular'
  .controller 'PublicController', ($scope, $rootScope, $stateParams, $state, $q, MnoeCurrentUser, MnoeOrganizations, MnoeConfig) ->
    'ngInject'

    unless MnoeConfig.arePublicPagesEnabled()
      $window.location = URI.login

    $rootScope.publicPage = true

    MnoeCurrentUser.get().then(
      (response) ->
        if response.logged_in
          $state.go('home.impac')
    )

    return
