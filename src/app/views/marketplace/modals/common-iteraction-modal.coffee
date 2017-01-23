angular.module 'mnoEnterpriseAngular'
.controller('CommonIteractionModal', ($scope, $uibModalInstance, iteractionObject) ->

  $scope.iteractionText = ''
  $scope.type = iteractionObject.type.context

  # Close the current modal
  $scope.closeModal = ->
    $uibModalInstance.dismiss()

  $scope.submitIteraction = ->
    switch $scope.type
      when 'comment'
        iteractionObject.object.comments.push({text: $scope.iteractionText})

    $uibModalInstance.dismiss()

  return
)
