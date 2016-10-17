angular.module 'mnoEnterpriseAngular'
.controller('DashboardAppConnectModalCtrl', ($scope, $uibModalInstance, app, $httpParamSerializer, $window, $http) ->

  $scope.app = app

  # Customization for myob & xero
  if app.app_nid == "myob"
    $scope.path = "/mnoe/webhook/oauth/" + app.uid + "/authorize?"
    $scope.myob = {
      versions: [{name: "Account Right Live", value: "account_right"}, {name: "Essentials", value: "essentials"}]
    }
    $scope.form = {
      perform: true
      version: "essentials"
    }
  else if app.app_nid == "xero"
    $scope.path = "/mnoe/webhook/oauth/" + app.uid + "/authorize?"
    $scope.xero = {
      countries: [{name: "Australia", value: "AU"}, {name: "USA", value: "US"}]
    }
    $scope.form = {
      perform: true
      xero_country: "AU"
    }

  $scope.connect = (form) ->
    form['extra_params[]'] = "payroll" if app.app_nid == "xero" && $scope.payroll
    $window.location.href = $scope.path + $httpParamSerializer(form)

  $scope.close = ->
    $uibModalInstance.close()

  return
)
