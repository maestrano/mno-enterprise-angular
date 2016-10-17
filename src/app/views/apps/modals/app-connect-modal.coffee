angular.module 'mnoEnterpriseAngular'
.controller('DashboardAppConnectModalCtrl', ($scope, $uibModalInstance, app, $httpParamSerializer, $window, $http) ->

  $scope.app = app
  $scope.path = "/mnoe/webhook/oauth/" + app.uid + "/authorize?"
  $scope.form = {
    perform: true
  }

  # Customization for myob & xero
  if app.app_nid == "myob"
    $scope.form.version: "essentials"
    $scope.myob = {
      versions: [{name: "Account Right Live", value: "account_right"}, {name: "Essentials", value: "essentials"}]
    }
  else if app.app_nid == "xero"
    $scope.form.xero_country = "AU"
    $scope.xero = {
      countries: [{name: "Australia", value: "AU"}, {name: "USA", value: "US"}]
    }

  $scope.connect = (form) ->
    form['extra_params[]'] = "payroll" if app.app_nid == "xero" && $scope.payroll
    $window.location.href = $scope.path + $httpParamSerializer(form)

  $scope.close = ->
    $uibModalInstance.close()

  return
)
