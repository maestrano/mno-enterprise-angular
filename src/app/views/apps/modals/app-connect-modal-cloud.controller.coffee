angular.module 'mnoEnterpriseAngular'
  .controller('DashboardAppConnectCloudModalCtrl', ($scope, $uibModalInstance, app, MnoeAppInstances) ->

    $scope.app = app

    MnoeAppInstances.getForm(app: app)
      .then((response) ->
        $scope.schema = response.schema
        $scope.form = response.form
      )

    $scope.model = {}
  
    $scope.close = ->
      $uibModalInstance.close()
  
    return
)
