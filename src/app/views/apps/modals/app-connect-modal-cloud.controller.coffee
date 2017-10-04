angular.module 'mnoEnterpriseAngular'
  .controller('DashboardAppConnectCloudModalCtrl', ($scope, $uibModalInstance, app, MnoeAppInstances, toastr) ->

    $scope.app = app
    $scope.model = {}
    $scope.hasLinked = false
    $scope.hasChosenEntities = false
    $scope.historicalData = false
    $scope.isFormLoading = true
    $scope.isSubmitting = false

    MnoeAppInstances.getForm(app)
      .then((response) ->
        $scope.schema = response.schema
        $scope.form = [ "*" ]
        $scope.isFormLoading = false
      )

    $scope.getDate = ->
      moment.locale('en')
      moment().format("dddd, MMMM Do YYYY, h:mm:ss a")

    $scope.historicalDataDisplay = ->
      if document.getElementById('historical-data').checked
        document.getElementById('historical-data-display-checked').style.display = 'block'
        document.getElementById('historical-data-display-unchecked').style.display = 'none'
      else
        document.getElementById('historical-data-display-unchecked').style.display = 'block'
        document.getElementById('historical-data-display-checked').style.display = 'none'
  
    $scope.close = ->
      $uibModalInstance.close()

    $scope.submit = (form) ->
      $scope.isSubmitting = true
      MnoeAppInstances.submitForm($scope.app, $scope.model)
        .then((response) ->
          if response.error
            toastr.error(response.error)
          else
            $scope.app.organization.has_account_linked = true
            $scope.hasLinked = true
          $scope.isSubmitting = false
        )

    $scope.update = (entities) ->
      $scope.hasChosenEntities = true

    $scope.synchronize = (historicalData) ->
      MnoeAppInstances.sync($scope.app, historicalData)
        .then((response) ->
          $uibModalInstance.close()
          toastr.success("Congratulations, your data is now being synced!")
        )
  
    return
)
