angular.module 'mnoEnterpriseAngular'
.controller('MarketplaceChooseOrgaModalCtrl', ($scope, $uibModalInstance, MnoeOrganizations, MnoeCurrentUser) ->

  # Initialize the main variables
  $scope.organizations = {}
  $scope.current_organization = {}
  $scope.authorized_organizations = {}  # The organizations where the user can add apps
  $scope.hasAuthorizedOrganizations = false
  $scope.isLoading = true

  # Get the current organization id
  $scope.current_organization = {
    id: MnoeOrganizations.selectedId
  }
  #  Get the list of all the user organizations
  MnoeCurrentUser.get().then(
    (response) ->  # Hash of organizations id -> {organization obj}
      $scope.filterAuthorizedOrga(response.organizations)
      $scope.hasAuthorizedOrganizations = !_.isEmpty($scope.authorized_organizations)
      $scope.isLoading = false
  )

  # Filter the authorized organizations for this user
  $scope.filterAuthorizedOrga = (organizations) ->
    organizations.map(
      (org) ->
        $scope.organizations[org.id] = org
        $scope.authorized_organizations[org.id] = org if MnoeOrganizations.role.atLeastPowerUser(org.current_user_role)
    )

  # Check if the user is allowed to add apps to the given organization
  $scope.isUserAuthorized = (orgId) ->
    currentUserRole = $scope.organizations[orgId].current_user_role
    MnoeOrganizations.role.atLeastPowerUser(currentUserRole)

  # Update current user authorization based on the selected org
  $scope.updateUserAuthorization = ->
    $scope.current_organization.isUserAuthorized = $scope.isUserAuthorized($scope.current_organization.id)

  # Add a new app instance to the current user organization
  $scope.addApplication = ->
    MnoeOrganizations.purchaseApp($scope.app, $scope.current_organization.id)

  # Close the current modal
  $scope.closeChooseOrgaModal = ->
    $uibModalInstance.close()

  return
)
