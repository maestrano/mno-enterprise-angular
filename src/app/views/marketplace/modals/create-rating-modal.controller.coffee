angular.module 'mnoEnterpriseAngular'
  .controller('CreateRatingModalCtrl', ($scope, $uibModalInstance, Utilities) ->

    $scope.modal = { model: {} }
    $scope.appRating = {rating: 5}

    $scope.modal.cancel = ->
      $uibModalInstance.dismiss('cancel')

    $scope.modal.proceed =  ->
      $scope.modal.isLoading = true
      data = { rating: { comment: $scope.modal.model.comment, rating: $scope.appRating.rating}}
      # MnoeMnoeMarketplace.create(data).then(
      #   (response) ->
      #     delete $scope.modal.errors
      #     $uibModalInstance.close(response)
      #   (errors) ->
      #     $scope.modal.errors = Utilities.processRailsError(errors)
      # ).finally(->
      #   $scope.modal.isLoading = false
      # )
  )
