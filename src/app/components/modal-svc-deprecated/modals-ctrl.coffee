angular.module 'mnoEnterpriseAngular'

# -------------------------------------------------------------------------
# This module is meant to contain the small controllers for simple modals
# For more complex modals, put the controller in its own file
# -------------------------------------------------------------------------

  #============================================
  # NewOrgModalCtrl
  #============================================
  .controller('NewOrgModalCtrl',
    ($scope, $modalInstance, Utilities, MnoeOrganizations, $modalInstanceCB) ->

      $scope.modal = { model: {} }

      $scope.modal.close = ->
        $modalInstance.close()

      $scope.modal.proceed =  ->
        $scope.modal.isLoading = true
        data = { organization: $scope.modal.model }
        MnoeOrganizations.create(data).then(
          (response) ->
            $scope.modal.errors = ''
            $scope.modal.close()
            # Callback method
            if $modalInstanceCB then $modalInstanceCB(response.organization)
          (errors) ->
            $scope.modal.errors = Utilities.processRailsError(errors)
        ).finally(->
          $scope.modal.isLoading = false
        )
  )
