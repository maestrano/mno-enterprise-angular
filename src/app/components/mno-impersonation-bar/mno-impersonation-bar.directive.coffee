
angular.module 'mnoEnterpriseAngular'
  .directive('mnoImpersonationBar', ->
    return {
      restrict: 'EA'
      template: '''
        <div id="impersonate-bar" class="row" ng-show="currentUser && currentUser.current_impersonator">
          <div class="col-sm-6 col-sm-offset-3 col-md-8 col-md-offset-2 text-center">
            You are impersonating {{currentUser.name}} {{currentUser.surname}} ({{currentUser.email}})
            <a class="btn btn-sm btn-warning" type="submit" ng-click="exitImpersonation()">Revert to admin</a>
          </div>
        </div>
      '''
      controller: ($scope, $window, MnoeCurrentUser) ->

        $scope.exitImpersonation = () ->
          $window.location.href = "/mnoe/impersonate/revert"

        MnoeCurrentUser.get().then(
          (response) ->
            $scope.currentUser = response
        )
    }
  )
