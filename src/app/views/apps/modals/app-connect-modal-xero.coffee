angular.module 'mnoEnterpriseAngular'
.controller('DashboardAppConnectXeroModalCtrl', ($scope, $window, $httpParamSerializer, $uibModalInstance, app) ->

  $scope.app = app
  $scope.path = "/mnoe/webhook/oauth/" + app.uid + "/authorize?"
  $scope.form = {
    perform: true
    xero_country: "AU"
  }
  $scope.countries = [{name: "Australia", value: "AU"}, {name: "USA", value: "US"}]

  $scope.connect = (form) ->
    form['extra_params[]'] = "payroll" if $scope.payroll
    $window.location.href = $scope.path + $httpParamSerializer(form)

  $scope.close = ->
    $uibModalInstance.close()

  return
)
