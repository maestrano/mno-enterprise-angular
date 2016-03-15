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
            $scope.modal.errors = null
            $uibModalInstance.close()
          (error) ->
            $scope.modal.errors = Utilities.processRailsError(error)
        ).finally(-> $scope.modal.loading = false)

      cancel: ->
        $uibModalInstance.dismiss('cancel')
)
