angular.module 'mnoEnterpriseAngular'
.controller('EditAnswerModalCtrl', ($log, $stateParams, $uibModalInstance, toastr, Utilities, MnoeMarketplace, object) ->
  vm = this

  vm.modal = {model: {}}
  vm.commentMaxLenght = 500

  vm.modal.model.description = object.description

  vm.modal.cancel = ->
    $uibModalInstance.dismiss('cancel')

  vm.modal.proceed = () ->
    vm.modal.isLoading = true
    app_payload = {
      description: vm.modal.model.description
    }

    MnoeMarketplace.editAnswer($stateParams.appId, object.id, app_payload).then(
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
