angular.module 'mnoEnterpriseAngular'
.controller('DeleteReviewModalCtrl', ($log, $stateParams, $uibModalInstance, toastr, Utilities, MnoeMarketplace, review) ->
  vm = this

  vm.modal = {model: {}}

  vm.modal.cancel = ->
    $uibModalInstance.dismiss('cancel')

  vm.modal.proceed = () ->
    vm.modal.isLoading = true

    MnoeMarketplace.deleteReview($stateParams.appId, review.id).then(
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
