angular.module 'mnoEnterpriseAngular'
.controller('EditReviewModalCtrl', ($log, $stateParams, $uibModalInstance, toastr, Utilities, MnoeMarketplace, review) ->
  vm = this

  vm.modal = {model: {}}
  vm.appRating = review.rating

  vm.commentMaxLenght = 500

  vm.modal.model.description = review.description

  vm.modal.cancel = ->
    $uibModalInstance.dismiss('cancel')

  vm.modal.proceed = () ->
    vm.modal.isLoading = true
    app_feedback = {
      description: vm.modal.model.description
      rating: vm.appRating
    }

    MnoeMarketplace.editReview($stateParams.appId, review.id, app_feedback).then(
      (response) ->
        toastr.success('mno_enterprise.templates.dashboard.marketplace.show.success_toastr_2')
        $uibModalInstance.close(response)
      (errors) ->
        $log.error(errors)
        toastr.error('mno_enterprise.templates.dashboard.marketplace.show.error_toastr')
        Utilities.processRailsError(errors)
    ).finally(-> vm.modal.isLoading = false)

  return
)
