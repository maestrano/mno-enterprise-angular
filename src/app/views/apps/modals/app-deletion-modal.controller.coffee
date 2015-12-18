angular.module 'mnoEnterpriseAngular'
  .controller('AppDeletionModalCtrl', ($scope, $uibModalInstance, MnoeAppInstances, Utilities, app) ->

    $scope.modal =
      app: app
      loading: false
      sentence: 'Please proceed to the deletion of my app and all data it contains'

      deleteApp: ->
        $scope.modal.loading = true
        MnoeAppInstances.terminate($scope.modal.app.id).then(
          (success) ->
            MnoeAppInstances.getAppInstances()
            $scope.modal.loading = false
            $scope.modal.errors = null
            $uibModalInstance.close()
          (error) ->
            $scope.modal.loading = false
            $scope.modal.errors = Utilities.processRailsError(error)
        )

      cancel: ->
        $uibModalInstance.dismiss('cancel')
)
