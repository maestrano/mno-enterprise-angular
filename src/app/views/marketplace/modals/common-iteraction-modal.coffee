angular.module 'mnoEnterpriseAngular'
.controller('CommonIteractionModal', ($scope, $uibModalInstance, iteractionObject) ->

  $scope.iteractionText = ''
  $scope.type = iteractionObject.type.context

  if $scope.type == 'answer'
    $scope.questionText = iteractionObject.object.text

  # Close the current modal
  $scope.closeModal = ->
    $uibModalInstance.dismiss()

  $scope.submitIteraction = ->
    switch $scope.type
      when 'comment'
        iteractionObject.object.comments.push({text: $scope.iteractionText})
      when 'question'
        iteractionObject.object.push({text: $scope.iteractionText, answers: []})
      when 'answer'
        iteractionObject.object.answers.push({text: $scope.iteractionText})

    $uibModalInstance.dismiss()

  return
)
