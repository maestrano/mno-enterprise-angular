angular.module 'mnoEnterpriseAngular'
  .controller('CreateRatingModalCtrl', ($scope, $uibModalInstance, Utilities, MnoeMarketplace, MnoeOrganizations, $stateParams) ->

    $scope.modal = { model: {} }
    $scope.appRating = {rating: 5}
    $scope.app = {}

    $scope.modal.cancel = ->
      $uibModalInstance.dismiss('cancel')

    $scope.modal.proceed = () ->
      $scope.modal.isLoading = true
      data = { rating: { rating: $scope.appRating.rating, description: $scope.modal.model.comment, organization_id: MnoeOrganizations.getSelectedId() }}
      MnoeMarketplace.updateApp(data, $stateParams.appId).then(
        (response) ->
          delete $scope.modal.errors
          # backend does not send a response yet
          $uibModalInstance.close(response)
        (errors) ->
          $scope.modal.errors = Utilities.processRailsError(errors)
      ).finally(->
        $scope.modal.isLoading = false
      )
  )
