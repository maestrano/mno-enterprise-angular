angular.module 'mnoEnterpriseAngular'
.controller('CreateCommentModalCtrl', ($log, $stateParams, $uibModalInstance, toastr, Utilities, MnoeMarketplace, MnoeOrganizations, feedback) ->
  vm = this

  vm.modal = {model: {}}
  vm.appRating = 0
  vm.commentMaxLenght = 500

  vm.modal.cancel = ->
    $uibModalInstance.dismiss('cancel')

  vm.modal.proceed = () ->
    vm.modal.isLoading = true
    app_comment = {
      description: vm.modal.model.description,
      organization_id: MnoeOrganizations.getSelectedId(),
      feedback_id: feedback.id
    }
    MnoeMarketplace.addAppReviewComment($stateParams.appId, app_comment).then(
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
