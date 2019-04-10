
# TODO: Remove DhbTeamSvc
DashboardOrganizationTeamsCtrl = ($scope, $window, $uibModal, $q, MnoeOrganizations, MnoeTeams, MnoeProductInstances, Utilities) ->
  'ngInject'

  #====================================
  # Pre-Initialization
  #====================================
  $scope.isLoading = true
  $scope.teams = []
  $scope.originalTeams = []
  $scope.productInstances = []

  #====================================
  # Scope Management
  #====================================
  # Initialize the data used by the directive
  $scope.initialize = (teams, productInstances) ->
    angular.copy(teams, $scope.teams)
    angular.copy(teams, $scope.originalTeams)
    realProductInstances = _.filter(productInstances, (i) -> i.status != 'terminated')
    angular.copy(realProductInstances, $scope.productInstances)
    $scope.isLoading = false

  $scope.isTeamEmpty = (team) ->
    team.users.length == 0

  $scope.hasTeams = ->
    $scope.teams.length > 0

  $scope.hasApps = ->
    $scope.productInstances.length > 0

  #====================================
  # Permissions matrix
  #====================================
  $scope.matrix = matrix = {}
  matrix.isLoading = false

  # Check if a team has access to the specified
  # product_instance
  # If productInstance is equal to the string 'all'
  # then it checks if the team has access to all
  # productInstances
  matrix.hasAccess = (team, productInstance) ->
    if angular.isString(productInstance) && productInstance == 'all'
      _.reduce($scope.productInstances,
        (memo, elem) ->
          memo && _.find(team.product_instances, (i)-> i.id == elem.id)?
        , true
      )
    else
      _.find(team.product_instances, (i)-> i.id == productInstance.id)?

  # Add access to the product if the team does not have
  # access and remove access if the team already
  # have access
  matrix.toggleAccess = (team, productInstance) ->
    self = matrix
    if (self.hasAccess(team, productInstance))
      self.removeAccess(team, productInstance)
    else
      self.addAccess(team, productInstance)

  # Add access to a specified productInstance
  # If productInstance is equal to the string 'all'
  # then it adds permissions to all productInstances
  matrix.addAccess = (team, productInstance) ->
    if angular.isString(productInstance) && productInstance == 'all'
      team.product_instances.length = 0
      angular.copy($scope.productInstances, team.product_instances)
    else
      unless _.find(team.product_instances, (e)-> e.id == productInstance.id)?
        team.product_instances.push(productInstance)

  # Remove access to a specified productInstance
  # If productInstance is equal to the string 'all'
  # then it removes permissions to all productInstances
  matrix.removeAccess = (team,productInstance) ->
    if angular.isString(productInstance) && productInstance == 'all'
      team.product_instances.length = 0
    else
      if (elem = _.find(team.product_instances, (e)-> e.id == productInstance.id))?
        idx = team.product_instances.indexOf(elem)
        team.product_instances.splice(idx,1)

  # Open the 'add team' modal
  matrix.addTeam = ->
    addTeamModal.open()

  # Open the 'remove team' modal
  matrix.removeTeam = (team)->
    teamDeletionModal.open(team)

  matrix.compileHash = (teams) ->
    _.reduce teams,
      (hash,t) ->
        hash += "#{t.id}:"
        hash += _.sortBy(_.pluck(t.product_instances,'id'),(n)->n).join()
        hash += "::"
      ,""

  matrix.isChanged = ->
    self = matrix
    self.compileHash($scope.teams) != self.compileHash($scope.originalTeams)

  matrix.cancel = ->
    _.each $scope.teams, (t) ->
      ot = _.find($scope.originalTeams,(e) -> e.id == t.id)
      angular.copy(ot.product_instances,t.product_instances)

  matrix.save = ->
    self = matrix
    self.isLoading = true

    qs = []
    _.each $scope.teams, (team) ->
      # Force empty array if no product_instances permissions
      realProductInstances = if team.product_instances.length >0 then team.product_instances else [{}]
      qs.push MnoeTeams.updateTeamProductInstances(team, realProductInstances)

    $q.all(qs).then(
      (->)
        self.errors = ''
        self.updateOriginalTeams()
      (errorsArray) ->
        self.errors = Utilities.processRailsError(errorsArray[0])
    ).finally(-> self.isLoading = false)

  matrix.updateOriginalTeams = ->
    _.each $scope.teams, (t) ->
      ot = _.find($scope.originalTeams,(e) -> e.id == t.id)
      angular.copy(t.product_instances,ot.product_instances)

  matrix.updateTeamName = (team) ->
    origTeam = _.find($scope.teams, (t) -> t.id == team.id)
    if team.name.length == 0
      team.name = origTeam.name
    else
      MnoeTeams.updateTeamName(team).then(
        (->)
          origTeam.name = team.name
        , ->
          team.name = origTeam.name
      )

  #====================================
  # Add Team modal
  #====================================
  $scope.addTeamModal = addTeamModal = {}
  addTeamModal.config = {
    instance: {
      backdrop: 'static'
      templateUrl: 'app/views/company/teams/modals/team-add-modal.html'
      size: 'lg'
      windowClass: 'inverse team-add-modal'
      scope: $scope
    }
  }

  # Open the modal
  addTeamModal.open = ->
    self = addTeamModal
    self.model = {}
    self.$instance = $uibModal.open(self.config.instance)
    self.isLoading = false

  # Close the modal
  addTeamModal.close = ->
    self = addTeamModal
    self.$instance.close()

  # Check if proceed btn should be
  # disabled
  addTeamModal.isProceedDisabled = ->
    self = addTeamModal
    !self.model.name? || self.model.name.length == 0

  # Create the team then close the
  # modal
  addTeamModal.proceed = ->
    self = addTeamModal
    self.isLoading = true
    MnoeTeams.addTeam(self.model).then(
      (team) ->
        self.errors = ''
        self.addToScope(team)
        self.close()
      (errors) ->
        self.errors = Utilities.processRailsError(errors)
    ).finally(-> self.isLoading = false)

  addTeamModal.addToScope = (team) ->
    $scope.teams.push(angular.copy(team))
    $scope.originalTeams.push(angular.copy(team))

  #====================================
  # Team Deletion Modal
  #====================================
  $scope.teamDeletionModal = teamDeletionModal = {}
  teamDeletionModal.config = {
    instance: {
      backdrop: 'static'
      templateUrl: 'app/views/company/teams/modals/team-delete-modal.html'
      size: 'lg'
      windowClass: 'inverse team-delete-modal'
      scope: $scope
    }
  }

  teamDeletionModal.open = (team) ->
    self = teamDeletionModal
    self.team = team
    self.$instance = $uibModal.open(self.config.instance)
    self.isLoading = false
    self.errors = ''

  teamDeletionModal.close = ->
    self = teamDeletionModal
    self.$instance.close()

  teamDeletionModal.proceed = ->
    self = teamDeletionModal
    self.isLoading = true
    MnoeTeams.deleteTeam(self.team.id).then(
      (data) ->
        self.errors = ''
        self.removeFromScope(self.team)
        self.close()
      (errors) ->
        self.errors = Utilities.processRailsError(errors)
    ).finally(-> self.isLoading = false)

  teamDeletionModal.removeFromScope = (team) ->
    team = _.find($scope.teams, (t) -> t.id == team.id)
    idx = $scope.teams.indexOf(team)
    $scope.teams.splice(idx,1) if idx >= 0

    team = _.find($scope.originalTeams, (t) -> t.id == team.id)
    idx = $scope.originalTeams.indexOf(team)
    $scope.originalTeams.splice(idx,1) if idx >= 0

  #====================================
  # Post-Initialization
  #====================================
  # Watch organization id and reload on change
  $scope.$watch(MnoeOrganizations.getSelectedId, (newValue) ->
    if newValue?
      # Get the new teams for this organization
      $q.all([MnoeTeams.getTeams(), MnoeProductInstances.getProductInstances()]).then(
        (responses) ->
          $scope.initialize(responses[0], responses[1])
      )
  )

angular.module 'mnoEnterpriseAngular'
  .directive('dashboardOrganizationTeams', ->
    return {
      restrict: 'A',
      scope: {
      },
      templateUrl: 'app/views/company/teams/organization-teams.html',
      controller: DashboardOrganizationTeamsCtrl
    }
  )
