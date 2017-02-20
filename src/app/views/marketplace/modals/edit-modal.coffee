angular.module 'mnoEnterpriseAngular'
.controller('EditModal', ($scope, $uibModalInstance, object) ->

  $scope.editText = object.text

  # Close the current modal
  $scope.closeModal = ->
    $uibModalInstance.dismiss()

  $scope.submitEdition = ->
    $uibModalInstance.close($scope.editText)

  return
)
