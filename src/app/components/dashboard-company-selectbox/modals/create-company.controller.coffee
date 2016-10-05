angular.module 'mnoEnterpriseAngular'
  .controller('CreateCompanyModalCtrl', ($scope, $uibModalInstance, Utilities, MnoeOrganizations) ->

    $scope.modal = { model: {} }

    $scope.modal.cancel = ->
      $uibModalInstance.dismiss('cancel')

    $scope.modal.proceed =  ->
      $scope.modal.isLoading = true
      data = { organization: $scope.modal.model }
      MnoeOrganizations.create(data).then(
        (response) ->
          delete $scope.modal.errors
          $uibModalInstance.close(response)
        (errors) ->
          $scope.modal.errors = Utilities.processRailsError(errors)
      ).finally(->
        $scope.modal.isLoading = false
      )
  )
