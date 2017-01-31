angular.module 'mnoEnterpriseAngular'
.controller('ReviewHistoryModalCtrl', ($uibModalInstance, MnoeMarketplace, review) ->
  vm = this

  vm.review = review
  vm.versions = []
  vm.isLoading = true

  # Close the current modal
  vm.closeModal = ->
    $uibModalInstance.dismiss('close')

  #====================================
  # Post-Initialization
  #====================================
  # Get the list of all the user organizations
  MnoeMarketplace.getReview(review.app_id, review.id).then(
    (response) ->
      vm.versions = response.versions
      vm.isLoading = false
  )

  return
)
