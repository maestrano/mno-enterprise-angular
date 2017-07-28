angular.module 'mnoEnterpriseAngular'
  .controller 'MessagesController', ($scope, $state, MnoeCurrentUser, MnoeOrganizations) ->
    'ngInject'

    vm = this

    #====================================
    # Post-Initialization
    #====================================
    # $scope.$watch(MnoeOrganizations.getSelectedId, (newValue, oldValue) ->
    #   MnoeCurrentUser.get().then(
    #     (response) ->
    #       # selectedOrg = _.find(response.organizations, {id: parseInt(newValue)})
    #       # Needs to be at least admin to display impac! or user is redirected to apps dashboard
    #       # if MnoeOrganizations.role.atLeastAdmin(selectedOrg.current_user_role)

    #       # else
    #       #   $state.go('home.apps')
    #   ) if newValue?
    # )

    return
