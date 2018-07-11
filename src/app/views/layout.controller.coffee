angular.module 'mnoEnterpriseAngular'
  .controller 'LayoutController', ($scope, $location, $stateParams, $state, $q, MnoeCurrentUser, MnoeOrganizations, MnoeConfig) ->
    'ngInject'

    # Used for the provisioning workflow
    # If we are changing/creating a new order we want the edit plan breacrumb, otherwise not.
    $scope.showOrder = () ->
      $location.$$search["editAction"].toLowerCase() in ["change", "new"]

    $scope.breadcrumbNumber = (number) ->
      if $scope.showOrder()
        number
      else
        number - 1

    # Impac! is displayed only to admin and super admin
    $scope.$watch(MnoeOrganizations.getSelectedId, (newValue) ->
      MnoeCurrentUser.get().then(
        (response) ->
          selectedOrg = _.find(response.organizations, {id: newValue})
          isAdmin = MnoeOrganizations.role.atLeastAdmin(selectedOrg.current_user_role)

          # We only check the role for those states
          if $state.is('home.impac') || $state.is('home.apps')
            if isAdmin
              $state.go('home.impac')
            else
              $state.go('home.apps')

          $scope.isCartEnabled = isAdmin && MnoeConfig.isProvisioningEnabled()
      ) if newValue?
    )

    return
