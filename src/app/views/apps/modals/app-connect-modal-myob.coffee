angular.module 'mnoEnterpriseAngular'
.controller('DashboardAppConnectMyobModalCtrl', ($scope, $window, $httpParamSerializer, $uibModalInstance, MnoeAppInstances, app) ->

  $scope.app = app
  $scope.path = MnoeAppInstances.oAuthConnectPath(app)
  $scope.form = {
    perform: true
    version: "essentials"
  }
  $scope.versions = [{name: "Account Right Live", value: "account_right"}, {name: "Essentials", value: "essentials"}]

  $scope.connect = (form) ->
    $window.location.href = $scope.path + $httpParamSerializer(form)

  $scope.close = ->
    $uibModalInstance.close()

  return
)
