angular.module 'mnoEnterpriseAngular'
.controller('AnswerModal', ($scope, $uibModalInstance, question) ->

  $scope.answerText = ''
  $scope.questionText = question.text

  # Close the current modal
  $scope.closeModal = ->
    $uibModalInstance.dismiss()

  $scope.submitAnswer = ->
    $uibModalInstance.close($scope.questionText)

  return
)
