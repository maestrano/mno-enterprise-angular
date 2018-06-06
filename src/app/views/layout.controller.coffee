angular.module 'mnoEnterpriseAngular'
  .controller 'LayoutController', ($scope, $location, $stateParams, $state, $q, MnoeCurrentUser, MnoeOrganizations) ->
    'ngInject'

    # Used for the provisioning workflow
    # If we are changing/creating a new order we want the edit plan breacrumb, otherwise not.
    $scope.showOrder = () ->
      $location.$$path.includes('provision', 'change')

    $scope.breadcrumbNumber = (number) ->
      if $scope.showOrder()
        number
      else
        number - 1

    # Impac! is displayed only to admin and super admin
    $scope.$watch(MnoeOrganizations.getSelectedId, (newValue) ->
      MnoeCurrentUser.get().then(
        (response) ->
          # We only check the role for those states
          if $state.is('home.impac') || $state.is('home.apps')
            selectedOrg = _.find(response.organizations, {id: newValue})
            if MnoeOrganizations.role.atLeastAdmin(selectedOrg.current_user_role)
              $state.go('home.impac')
            else
              $state.go('home.apps')
      ) if newValue?
    )

    return
