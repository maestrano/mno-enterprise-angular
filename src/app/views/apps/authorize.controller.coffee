angular.module 'mnoEnterpriseAngular'
  .controller('AppAuthController',
    ($state, $window, $timeout, $stateParams, MnoErrorsHandler) ->

      $timeout(
        ->
          $window.location.href = $stateParams.redirect_path
      , 3000)

      return
  )
