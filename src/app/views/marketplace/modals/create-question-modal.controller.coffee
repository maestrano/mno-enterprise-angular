angular.module 'mnoEnterpriseAngular'
.controller('CreateQuestionModalCtrl', ($log, $stateParams, $uibModalInstance, toastr, Utilities, MnoeMarketplace, MnoeOrganizations) ->
  vm = this

  vm.modal = {model: {}}
  vm.commentMaxLenght = 500

  vm.modal.cancel = ->
    $uibModalInstance.dismiss('cancel')

  vm.modal.proceed = () ->
    vm.modal.isLoading = true
    app_review = {
      description: vm.modal.model.description,
      organization_id: MnoeOrganizations.getSelectedId()
    }
    MnoeMarketplace.addAppQuestion($stateParams.appId, app_review).then(
      (response) ->
        toastr.success('mno_enterprise.templates.dashboard.marketplace.show.success_toastr_question')
        $uibModalInstance.close(response)
      (errors) ->
        $log.error(errors)
        toastr.error('mno_enterprise.templates.dashboard.marketplace.show.error_toastr_question')
        Utilities.processRailsError(errors)
    ).finally(-> vm.modal.isLoading = false)

  return
)
