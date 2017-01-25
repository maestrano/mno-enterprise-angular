angular.module 'mnoEnterpriseAngular'
.controller('CommentModal', ($scope, $uibModalInstance) ->

  $scope.commentText = ''

  # Close the current modal
  $scope.closeModal = ->
    $uibModalInstance.dismiss()

  $scope.submitIteraction = ->
    $uibModalInstance.close($scope.commentText)
    # testimonial.comments.push({text: $scope.commentText})
    # $uibModalInstance.dismiss()

  return
)
