
#============================================
#
#============================================
DashboardCompanySelectboxCtrl = ($scope, $location, $stateParams, $cookies, $sce, $uibModal,
  MnoeCurrentUser, DashboardAppsDocument, DhbOrganizationSvc, MarketplaceSvc, DhbTeamSvc, MsgBus, ModalSvc) ->

    #====================================
    # Select Box
    #====================================
    $scope.selectBox = selectBox = {
      form: {}
      isClosed: true
      isShown: false
      user: undefined
      organizations: []
      userLabel: ''
    }

    selectBox.initialize = (currentUser) ->
      selectBox.user = currentUser
      selectBox.userLabel = "#{selectBox.user.name} #{selectBox.user.surname}"
      selectBox.organizations = selectBox.user.organizations

      # Capture parameters internally
      if $stateParams.new_app
        MsgBus.publish('params', {new_app: $stateParams.new_app})
        $location.search('new_app', null)

      # Attempt to load organization from param
      if (val = $stateParams.dhbRefId)
        val = parseInt(val)
        $location.search('dhbRefId', null)
        selectBox.organization = _.findWhere(selectBox.organizations,{id: val})

      # Attempt to load last organization from cookie
      if !selectBox.organization? && (val = $cookies.get('dhb_ref_id'))
        selectBox.organization = _.findWhere(selectBox.organizations,{id: val})

      # Default to first one otherwise
      unless selectBox.organization?
        selectBox.organization = selectBox.organizations[0]

      # return false if the user is member or reseller of at least one organization
      $scope.selectBoxisEmpty = ->
        !(selectBox.organization && selectBox.organization.id)

      # if the selectBox is empty, then by default we show the account tab
      # note: That condition will be true when a reseller has just signed up after
      # accepting an invitation to join a reseller organization. At that stage
      # he may not have any customers and he won't have any personal organization.
      if $scope.selectBoxisEmpty()
        $location.path('/account')
      # otherwise we change the selectbox to the organization loaded
      else
        # Switch dashboard to organization
        selectBox.changeTo(selectBox.organization)

    selectBox.toggle = ->
      selectBox.isClosed = !selectBox.isClosed

    selectBox.close = ->
      selectBox.isClosed = true

    selectBox.organizationList = ->
      return _.sortBy(selectBox.organizations, (o) -> o.name)

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

    #====================================
    # New Orga Modal
    #====================================
    newOrgModal = ModalSvc.newOrgModal({
      callback: (data) ->
        selectBox.changeTo(data)
    })

    MnoeCurrentUser.get().then(
      (response) ->
        selectBox.initialize(response)
    )


angular.module 'mnoEnterpriseAngular'
  .directive('dashboardCompanySelectbox', ->
    return {
      restrict: 'EA'
      controller: DashboardCompanySelectboxCtrl
      templateUrl: 'app/components/dashboard-company-selectbox/dashboard-company-selectbox.html',
    }
  )
