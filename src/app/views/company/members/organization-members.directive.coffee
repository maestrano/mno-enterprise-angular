
#============================================
#
#============================================
DashboardOrganizationMembersCtrl = ($scope, $modal, $sce, MnoeOrganizations, MnoeTeams, Utilities) ->
  'ngInject'

  #====================================
  # Pre-Initialization
  #====================================
  $scope.members = []
  $scope.teams = []
  $scope.isLoading = true
  updateNbOfSuperAdmin = ->
    $scope.hasManySuperAdmin = _.filter($scope.members, {'role': 'Super Admin'}).length <= 1

  #====================================
  # Scope Management
  #====================================
  # Initialize the data used by the directive
  $scope.initialize = (members, teams = nil) ->
    $scope.members = members
    $scope.teams = teams if teams
    $scope.isLoading = false
    updateNbOfSuperAdmin()

  $scope.editMember = (member) ->
    $scope.editionModal.open(member)

  $scope.removeMember = (member) ->
    $scope.deletionModal.open(member)

  $scope.inviteMembers = ->
    $scope.inviteModal.open()

  $scope.isInviteShown = ->
    MnoeOrganizations.can.create.member()

  $scope.isEditShown = (member) ->
    MnoeOrganizations.can.update.member(member, $scope.hasManySuperAdmin)

  $scope.isRemoveShown = (member) ->
    MnoeOrganizations.can.destroy.member(member, $scope.hasManySuperAdmin)

  $scope.memberRoleLabel = (member) ->
    if member.entity == 'User'
      return member.role
    else
      return "Invited (#{member.role})"

  #====================================
  # User Edition Modal
  #====================================
  $scope.editionModal = editionModal = {}
  editionModal.config = {
    instance: {
      backdrop: 'static'
      templateUrl: 'app/views/company/members/modals/edition-modal.html'
      size: 'lg'
      windowClass: 'inverse member-edit'
      scope: $scope
    }
    roles: ['Member','Power User','Admin','Super Admin']
  }

  editionModal.open = (member) ->
    self = editionModal
    self.member = member
    self.selectedRole = member.role
    self.$instance = $modal.open(self.config.instance)
    self.isLoading = false
    editionModal.member = member

  editionModal.close = ->
    self = editionModal
    self.$instance.close()

  editionModal.select = (role) ->
    editionModal.selectedRole = role

  editionModal.classForRole = (role) ->
    self = editionModal
    if role == self.member.role
      return 'btn-info'
    else if role == self.selectedRole
      return 'btn-warning'
    else
      return ''

  editionModal.isChangeDisabled = ->
    editionModal.member.role == editionModal.selectedRole

  editionModal.change = ->
    self = editionModal
    self.isLoading = true
    obj = { email: self.member.email, role: self.selectedRole }
    MnoeOrganizations.updateMember(obj).then(
      (members) ->
        self.errors = ''
        angular.copy(members, $scope.members)
        updateNbOfSuperAdmin()
        self.close()
      (errors) ->
        self.errors = Utilities.processRailsError(errors)
    ).finally(-> self.isLoading = false)

  #====================================
  # User Deletion Modal
  #====================================
  $scope.deletionModal = deletionModal = {}
  deletionModal.config = {
    instance: {
      backdrop: 'static'
      templateUrl: 'app/views/company/members/modals/removal-modal.html'
      size: 'lg'
      windowClass: 'inverse member-edit'
      scope: $scope
    }
  }

  deletionModal.open = (member) ->
    self = deletionModal
    self.member = member
    self.$instance = $modal.open(self.config.instance)
    self.isLoading = false
    self.member = member

  deletionModal.close = ->
    self = deletionModal
    self.$instance.close()

  deletionModal.hasName = ->
    m = deletionModal.member
    m.entity == 'User' && m.name?

  deletionModal.remove = ->
    self = deletionModal
    self.isLoading = true
    MnoeOrganizations.deleteMember(deletionModal.member).then(
      (members) ->
        self.errors = ''
        angular.copy(members, $scope.members)
        self.close()
      (errors) ->
        self.errors = Utilities.processRailsError(errors)
    ).finally(-> self.isLoading = false)

  #====================================
  # Invite Modal
  #====================================
  $scope.inviteModal = inviteModal = {}
  inviteModal.config = {
    instance: {
      backdrop: 'static'
      templateUrl: 'app/views/company/members/modals/invite-modal.html'
      size: 'lg'
      windowClass: 'inverse member-edit'
      scope: $scope
    }
    defaultRole: 'Member'
    roles: ->
      list = ['Member','Power User','Admin']
      list.push('Super Admin') if MnoeOrganizations.role.isSuperAdmin()
      return list
    teams: ->
      $scope.teams
  }

  inviteModal.open = () ->
    self = inviteModal
    self.$instance = $modal.open(self.config.instance)
    self.isLoading = false
    self.members = []
    self.userEmails = ''
    self.step = 'enterEmails'
    self.roleList = self.config.roles()
    self.teamList = self.config.teams()
    self.invalidEmails = []

  inviteModal.close = ->
    self = inviteModal
    self.$instance.close()

  inviteModal.isTeamListShown = ->
    inviteModal.teamList.length > 0

  inviteModal.title = ->
    self = inviteModal
    if self.step == 'enterEmails'
      return $sce.trustAsHtml("Enter email addresses")
    else
      return $sce.trustAsHtml("Select role for each new member")

  inviteModal.labelForAction = ->
    if inviteModal.step == 'enterEmails'
      return "Next"
    else
      return "Invite"

  inviteModal.next = ->
    self = inviteModal
    if self.step == 'enterEmails'
      inviteModal.processEmails()
    else
      inviteModal.inviteMembers()

  inviteModal.isNextEnabled = ->
    self = inviteModal
    self.step == 'defineRoles' || (self.step == 'enterEmails' && self.userEmails.length > 0)

  inviteModal.oneValidEmail = ->
    self = inviteModal
    res = false
    _.each self.userEmails.split("\n"), (email) ->
      res = true if email.match(email_regexp)
    return res

  inviteModal.processEmails = ->
    self = inviteModal
    self.isLoading = true
    self.members = []
    self.invalidEmails = []

    _.each self.userEmails.split("\n"), (email) ->
      email_regexp = /^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}$/i
      if email.match(email_regexp)
        self.members.push({email: email, role: self.config.defaultRole })
      else
        self.invalidEmails.push(email)

    self.isLoading = false
    if self.invalidEmails.length == 0
      self.step = 'defineRoles'

  inviteModal.inviteMembers = ->
    self = inviteModal
    self.isLoading = true
    MnoeOrganizations.inviteMembers(self.members).then(
      (members) ->
        self.errors = ''
        angular.copy(members, $scope.members)
        self.close()
      (errors) ->
        self.errors = Utilities.processRailsError(errors)
    ).finally(-> self.isLoading = false)


  #====================================
  # Post-Initialization
  #====================================
  $scope.$watch(MnoeOrganizations.getSelected, (newValue) ->
    if newValue?
      # Get the new teams for this organization
      MnoeTeams.getTeams().then(
        (response) ->
          $scope.initialize(MnoeOrganizations.selected.organization.members, MnoeTeams.teams)
      )
  )


angular.module 'mnoEnterpriseAngular'
  .directive('dashboardOrganizationMembers', ->
    return {
      restrict: 'A',
      scope: {
      },
      templateUrl: 'app/views/company/members/organization-members.html',
      controller: DashboardOrganizationMembersCtrl
    }
  )
