angular.module 'mnoEnterpriseAngular'
.controller('EditQuestionModalCtrl', ($log, $stateParams, $uibModalInstance, toastr, Utilities, MnoeMarketplace, question) ->
  vm = this

  vm.modal = {model: {}}
  vm.appRating = question.rating

  vm.commentMaxLenght = 500

  vm.modal.model.description = question.description

  vm.modal.cancel = ->
    $uibModalInstance.dismiss('cancel')

  vm.modal.proceed = () ->
    vm.modal.isLoading = true
    app_question = {
      description: vm.modal.model.description
    }

    MnoeMarketplace.editQuestion($stateParams.appId, question.id, app_question).then(
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
