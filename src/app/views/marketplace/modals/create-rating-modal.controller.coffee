angular.module 'mnoEnterpriseAngular'
  .controller('CreateRatingModalCtrl', ($scope, $stateParams, $uibModalInstance, Utilities, MnoeMarketplace, MnoeOrganizations, MnoeCurrentUser) ->

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
          # this code is to stab the back end for the meantime until the response is ready, then it will be replaced by the code at the bottom one.
          MnoeCurrentUser.get().then( (response) ->
            current_user = response.name + ' ' + response.surname
            currentorg = MnoeOrganizations.getSelected()
            $uibModalInstance.close({rating: data.rating.rating,description: data.rating.description, user_name: current_user, organization_name: currentorg.organization.name})
          )
          # this is the code that will work once the backend is ready
          # $uibModalInstance.close(response)
        (errors) ->
          $scope.modal.errors = Utilities.processRailsError(errors)
      ).finally(-> $scope.modal.isLoading = false)

    return
  )
