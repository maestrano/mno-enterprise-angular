#============================================
#
#============================================
DashboardOrganizationTeamListCtrl = ($scope, $window, $uibModal, $q, MnoeCurrentUser, MnoeOrganizations, MnoeTeams, MnoeAppInstances, Utilities) ->
  'ngInject'

  #====================================
  # Pre-Initialization
  #====================================
  $scope.isLoading = true
  $scope.teams = []
  $scope.organization = MnoeOrganizations.selected.organization

  #====================================
  # Scope Management
  #====================================
  # Initialize the data used by the directive
  # If the current user is not a manager then
  # the directive restricts the list to the current
  # user's teams only
  $scope.initialize = (teams) ->
    realTeams = []
    if $scope.canManageTeam()
      realTeams = teams
    else
      _.each teams, (t) ->
        realTeams.push(t) if $scope.teamHasUser(t, MnoeCurrentUser.user)

    angular.copy(realTeams, $scope.teams)
    $scope.isLoading = false

  $scope.isTeamEmpty = (team) ->
    team.users.length == 0

  $scope.hasTeams = ->
    $scope.teams.length > 0

  $scope.canManageTeam = ->
    MnoeOrganizations.can.create.member()

  $scope.teamHasUser = (team, user) ->
    _.find(team.users,(u)-> u.id == user.id)?

  $scope.memberRoleLabel = (user) ->
    "mno_enterprise.templates.dashboard.organization.members.roles." +  _.snakeCase(user.role)

  #====================================
  # Team: Member Add Modal
  #====================================
  $scope.openAddTeamMemberModal = (team) ->
    modalInstance = $uibModal.open(
      templateUrl: 'app/views/company/team-list/modals/member-add-modal.html'
      controller: 'MemberAddModalCtrl'
      controllerAs: 'vm'
      backdrop: 'static'
      windowClass: 'member-add-modal'
      size: 'lg'
      resolve:
        team: team
        availableUsers: -> getAvailableUsers(team)
    )
    modalInstance.result.then(
      ->
        angular.copy(MnoeTeams.teams, $scope.teams)
    )

  getAvailableUsers = (team) ->
    _.reject($scope.organization.members, (member) ->
      member.entity != 'User' || _.find(team.users, {'id': member.id})
    )

  $scope.usersAreAvailableToAdd = (team) ->
    getAvailableUsers(team).length > 1

  #====================================
  # Team: Member Removal Modal
  #====================================
  $scope.memberRemovalModal = memberRemovalModal = {}
  memberRemovalModal.config = {
    instance: {
      backdrop: 'static'
      templateUrl: 'app/views/company/team-list/modals/member-removal-modal.html'
      size: 'lg'
      windowClass: 'inverse team-member-removal-modal'
      scope: $scope
    }
  }

  memberRemovalModal.open = (team, user) ->
    self = memberRemovalModal
    self.team = team
    self.user = user
    self.$instance = $uibModal.open(self.config.instance)
    self.isLoading = false

  memberRemovalModal.close = ->
    self = memberRemovalModal
    self.$instance.close()

  memberRemovalModal.proceed = ->
    self = memberRemovalModal
    self.isLoading = true
    MnoeTeams.removeUser(self.team.id, self.user).then(
      (users) ->
        self.errors = ''
        angular.copy(users, self.team.users)
        self.close()
      (errors) ->
        self.errors = Utilities.processRailsError(errors)
    ).finally(-> self.isLoading = false)

  #====================================
  # Post-Initialization
  #====================================
  $scope.$watch(MnoeOrganizations.getSelectedId, (newValue) ->
    if newValue?
      # Get the new teams for this organization
      MnoeTeams.getTeams().then(
        (responses) ->
          $scope.initialize(responses)
      )
  )

  $scope.$watch(
    () -> MnoeTeams.teams.length,
    (newValue) ->
      if newValue?
        $scope.initialize(MnoeTeams.teams)
  )

angular.module 'mnoEnterpriseAngular'
  .directive('dashboardOrganizationTeamList', () ->
    return {
      restrict: 'A',
      scope: {
        title: '@'
      },
      templateUrl: 'app/views/company/team-list/team-list.html',
      controller: DashboardOrganizationTeamListCtrl
    }
  )
