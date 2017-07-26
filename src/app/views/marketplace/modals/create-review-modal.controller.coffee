angular.module 'mnoEnterpriseAngular'
.controller('CreateReviewModalCtrl', ($log, $uibModalInstance, toastr, Utilities, MnoeMarketplace, MnoeOrganizations, app) ->
  vm = this

  vm.modal = {model: {}}
  vm.appRating = 0
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
    MnoeMarketplace.addAppReview(app.id, app_review).then(
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
