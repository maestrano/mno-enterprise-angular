angular.module 'mnoEnterpriseAngular'
.controller('CreateAnswerModalCtrl', ($log, $uibModalInstance, toastr, Utilities, MnoeMarketplace, MnoeOrganizations, question, app) ->
  vm = this

  vm.modal = {model: {}}
  vm.commentMaxLenght = 500
  vm.questionText = question.description

  vm.modal.cancel = ->
    $uibModalInstance.dismiss('cancel')

  vm.modal.proceed = () ->
    vm.modal.isLoading = true
    app_question = {
      description: vm.modal.model.description,
      organization_id: MnoeOrganizations.getSelectedId(),
      parent_id: question.id
    }
    MnoeMarketplace.addAppQuestionAnswer(app.id, app_question).then(
      (response) ->
        toastr.success('mno_enterprise.templates.dashboard.marketplace.show.success_toastr_answer')
        $uibModalInstance.close(response)
      (errors) ->
        $log.error(errors)
        toastr.error('mno_enterprise.templates.dashboard.marketplace.show.error_toastr_answer')
        Utilities.processRailsError(errors)
    ).finally(-> vm.modal.isLoading = false)

  return
)
