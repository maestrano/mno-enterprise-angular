angular.module 'mnoEnterpriseAngular'
.controller('CreateReviewModalCtrl', ($scope, $stateParams, $uibModalInstance, Utilities, MnoeMarketplace, MnoeOrganizations, MnoeCurrentUser) ->
  vm = this

  vm.modal = {model: {}}
  vm.appRating = 5
  vm.app = {}
  vm.commentMaxLenght = 500

  vm.modal.cancel = ->
    $uibModalInstance.dismiss('cancel')

  vm.modal.proceed = () ->
    vm.modal.isLoading = true
    app_review = {
      rating: vm.appRating,
      description: vm.modal.model.description,
      organization_id: MnoeOrganizations.getSelectedId()
    }
    MnoeMarketplace.addAppReview($stateParams.appId, app_review).then(
      (response) ->
        delete vm.modal.errors
        $uibModalInstance.close(response)
      (errors) ->
        vm.modal.errors = Utilities.processRailsError(errors)
    ).finally(-> $scope.modal.isLoading = false)

  return
)
