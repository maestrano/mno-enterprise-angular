angular.module 'mnoEnterpriseAngular'
  .controller('DashboardAppConnectCloudModalCtrl', ($scope, $uibModalInstance, app, MnoeAppInstances, toastr) ->

    $scope.app = app
    $scope.model = {}
    $scope.hasLinked = app.addon_organization.has_account_linked
    $scope.hasChosenEntities = false
    $scope.historicalData = false
    $scope.isFormLoading = true
    $scope.isSubmitting = false
    $scope.historicalData = false
    $scope.date = new Date()

    MnoeAppInstances.getForm(app)
      .then((response) ->
        $scope.schema = response.schema
        $scope.form = [ "*" ]
        $scope.isFormLoading = false
      )

    $scope.close = ->
      $uibModalInstance.close()

    $scope.submit = (form) ->
      $scope.isSubmitting = true
      MnoeAppInstances.submitForm($scope.app, $scope.model)
        .then((response) ->
          if response.error
            toastr.error(response.error)
          else
            $scope.app.addon_organization.has_account_linked = true
            $scope.hasLinked = true
          $scope.isSubmitting = false
        )

    $scope.unselectEntities = ->
      $scope.hasChosenEntities = false

    $scope.forceSelectEntities = ->
      $scope.hasChosenEntities = true

    $scope.update = (entities) ->
      $scope.hasChosenEntities = true

    $scope.synchronize = (historicalData) ->
      MnoeAppInstances.sync($scope.app, historicalData)
      $scope.app.addon_organization.sync_enabled = true
      $uibModalInstance.close()
      toastr.success("Congratulations, your data is now being synced!")

    $scope.titleForButton = ->
      if !$scope.hasLinked
        "Submit"
      else if !$scope.hasChosenEntities
        "Update"
      else
        "Start synchronizing"

    $scope.callToAction = (connectForm, historicalData)->
      if !$scope.hasLinked
        $scope.submit(connectForm)
      else if !$scope.hasChosenEntities
        $scope.update(app.addon_organization.synchronized_entities)
      else
        $scope.synchronize(historicalData)

    return
)
