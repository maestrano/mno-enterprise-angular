
#============================================
#
#============================================
DashboardCompanySelectboxCtrl = ($scope, $location, $stateParams, $cookies, $sce, $uibModal,
  CurrentUserSvc, DashboardAppsDocument, DhbOrganizationSvc, MarketplaceSvc, DhbTeamSvc, MsgBus, ModalSvc) ->

    #====================================
    # Pre-Initialization
    # Here we initialize all the services that do not depend on
    # the current organization
    #====================================
    MarketplaceSvc.setup()

    #====================================
    # Scope Management
    #====================================
    # Check path or root path
    $scope.isButtonActive = (entity) ->
      $location.url() == entity ||
      $location.url().split("/")[1] == entity.split("/")[1]

    # Note: Unused at the moment
    $scope.reloadServices = (orgId) ->
      DashboardAppsDocument.setup(id: orgId)
      DhbOrganizationSvc.setup(id: orgId)
      DhbTeamSvc.setup(id: orgId)

    #====================================
    # Select Box
    #====================================
    $scope.selectBox = selectBox = {}
    selectBox.form = {}
    selectBox.isClosed = true
    selectBox.isShown = false
    selectBox.user = undefined
    selectBox.organizations = []
    selectBox.userLabel = ''

    selectBox.initialize = (currentUser) ->
      self = selectBox
      self.user = currentUser
      self.userLabel = "#{self.user.name} #{self.user.surname}"
      self.organizations = self.user.organizations

      # Capture parameters internally
      if $stateParams.new_app
        MsgBus.publish('params', {new_app: $stateParams.new_app})
        $location.search('new_app', null )

      # Attempt to load organization from param
      if (val = $stateParams.dhbRefId)
        val = parseInt(val)
        $location.search('dhbRefId', null)
        self.organization = _.findWhere(self.organizations,{id: val})

      # Attempt to load last organization from cookie
      if !self.organization? && (val = $cookies.get('dhb_ref_id'))
        self.organization = _.findWhere(self.organizations,{id: val})

      # Default to first one otherwise
      unless self.organization?
        self.organization = self.organizations[0]

      # return false if the user is member or reseller of at least one organization
      $scope.selectBoxisEmpty = ->
        !(self.organization && self.organization.id)

      # if the selectBox is empty, then by default we show the account tab
      # note: That condition will be true when a reseller has just signed up after
      # accepting an invitation to join a reseller organization. At that stage
      # he may not have any customers and he won't have any personal organization.
      if $scope.selectBoxisEmpty()
        $location.path('/account')
      # otherwise we change the selectbox to the organization loaded
      else
        # Switch dashboard to organization
        selectBox.changeTo(self.organization)

    selectBox.toggle = ->
      selectBox.isClosed = !selectBox.isClosed

    selectBox.close = ->
      selectBox.isClosed = true

    selectBox.organizationList = ->
      self = selectBox
      return _.sortBy(self.organizations, (o) -> o.name)

    # Format the html of the label used by the provided
    # organization, based on whether it is selected, is a customer, reseller
    # or regular company
    selectBox.organizationLabel = (organization) ->
      icon = {}
      icon.type = if (organization.id == DhbOrganizationSvc.getId()) then "fa-dot-circle-o" else "fa-circle-o"
      return $sce.trustAsHtml("<i class=\"fa #{icon.type}\"></i>#{organization.name}")

    # TODO: This function should go in a service
    selectBox.changeTo = (organization) ->
      DashboardAppsDocument.setup(id: organization.id)
      DhbOrganizationSvc.setup(id: organization.id)
      DhbTeamSvc.setup(id: organization.id)
      $cookies.put('dhb_ref_id', organization.id)
      selectBox.organization = organization
      selectBox.close()

    selectBox.createNewOrga = ->
      newOrgModal.open()
      selectBox.close()

    # Analytics tab is only enabled for certain users
    # To enable access, do:
    # user.put_metadata('has_analytics_beta_access',true)
    $scope.isAnalyticsTabShown = ->
      return CurrentUserSvc.document &&
      CurrentUserSvc.document.current_user &&
      CurrentUserSvc.document.current_user.hasAnalyticsBetaAccess

    #====================================
    # New Orga Modal
    #====================================
    newOrgModal = ModalSvc.newOrgModal({
      callback: (data) ->
        selectBox.changeTo(data)
    })

    CurrentUserSvc.loadDocument().then (data) ->
      selectBox.initialize(CurrentUserSvc.document.current_user)


angular.module 'mnoEnterpriseAngular'
  .directive('dashboardCompanySelectbox', ->
    return {
      restrict: 'EA'
      controller: DashboardCompanySelectboxCtrl
      templateUrl: 'app/components/dashboard-company-selectbox/dashboard-company-selectbox.html',
    }
  )
