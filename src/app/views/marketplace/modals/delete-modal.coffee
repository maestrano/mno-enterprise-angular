angular.module 'mnoEnterpriseAngular'
.controller('DeleteModal', ($scope, $uibModalInstance) ->

  # Close the current modal
  $scope.closeModal = ->
    $uibModalInstance.dismiss()

  $scope.submitDeletion = ->
    $uibModalInstance.close(true)

  return
)
