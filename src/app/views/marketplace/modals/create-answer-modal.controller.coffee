angular.module 'mnoEnterpriseAngular'
.controller('CreateAnswerModalCtrl', ($log, $stateParams, $uibModalInstance, toastr, Utilities, MnoeMarketplace, MnoeOrganizations, question) ->
  vm = this

  vm.modal = {model: {}}
  vm.app = {}
  vm.commentMaxLenght = 500
  vm.questionText = question.description

  vm.modal.cancel = ->
    $uibModalInstance.dismiss('cancel')

  vm.modal.proceed = () ->
    vm.modal.isLoading = true
    app_question = {
      description: vm.modal.model.description,
      organization_id: MnoeOrganizations.getSelectedId(),
      question_id: question.id
    }
    MnoeMarketplace.addAppQuestionAnswer($stateParams.appId, app_question).then(
      (response) ->
        toastr.success('mno_enterprise.templates.dashboard.marketplace.show.success_toastr')
        $uibModalInstance.close(response)
      (errors) ->
        $log.error(errors)
        toastr.error('mno_enterprise.templates.dashboard.marketplace.show.error_toastr')
        Utilities.processRailsError(errors)
    ).finally(-> vm.modal.isLoading = false)

  return
)
