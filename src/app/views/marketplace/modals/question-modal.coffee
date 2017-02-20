angular.module 'mnoEnterpriseAngular'
.controller('QuestionModal', ($scope, $uibModalInstance) ->

  $scope.questionText = ''

  # Close the current modal
  $scope.closeModal = ->
    $uibModalInstance.dismiss()

  $scope.submitQuestion = ->
    $uibModalInstance.close($scope.questionText)

  return
)
