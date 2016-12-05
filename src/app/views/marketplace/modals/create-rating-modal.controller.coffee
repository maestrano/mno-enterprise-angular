angular.module 'mnoEnterpriseAngular'
  .controller('CreateRatingModalCtrl', ($scope, $stateParams, $uibModalInstance, Utilities, MnoeMarketplace, MnoeOrganizations) ->

    vm = this

    vm.modal = {model: {}}
    vm.appRating = 5
    vm.app = {}

    vm.modal.cancel = ->
      $uibModalInstance.dismiss('cancel')

    vm.modal.proceed = () ->
      vm.modal.isLoading = true
      data = {rating: {rating: vm.appRating, description: vm.modal.model.comment, organization_id: MnoeOrganizations.getSelectedId()}}
      MnoeMarketplace.updateApp(data, $stateParams.appId).then(
        (response) ->
          delete vm.modal.errors
          $uibModalInstance.close(response)
        (errors) ->
          $scope.modal.errors = Utilities.processRailsError(errors)
      ).finally(-> $scope.modal.isLoading = false)

    return
  )
