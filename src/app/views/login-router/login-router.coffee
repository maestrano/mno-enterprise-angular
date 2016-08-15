angular.module 'mnoEnterpriseAngular'
  .controller 'LoginRouterCtrl', ($scope, MnoeCurrentUser, $window) ->
    'ngInject'

    $scope.init = MnoeCurrentUser.get().then(
      (success) ->
        self.current_user_role = MnoeCurrentUser.user.organizations[0].current_user_role
        if self.current_user_role == 'Super Admin' || self.current_user_role == 'Admin'
          window.location.href = "/dashboard/#/impac"
        else
          window.location.href = "/dashboard/#/apps"
    )
