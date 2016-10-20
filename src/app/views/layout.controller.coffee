angular.module 'mnoEnterpriseAngular'
  .controller 'LayoutController', ($scope, $stateParams, $state, $q, MnoeCurrentUser, MnoeOrganizations) ->
    'ngInject'

    # Impac! is displayed only to admin and super admin
    $scope.$watch(MnoeOrganizations.getSelectedId, (newValue) ->
      MnoeCurrentUser.get().then(
        (response) ->
          selectedOrg = _.find(response.organizations, {id: parseInt(newValue)})
          if selectedOrg.current_user_role == "Super Admin" || selectedOrg.current_user_role == "Admin"
            $state.go('home.impac')
          else
            $state.go('home.apps')
      ) if newValue?
    )

    return
