
#============================================
#
#============================================
DashboardCompanySelectboxCtrl = ($scope, $state, $stateParams, $uibModal, MnoeCurrentUser, MnoeOrganizations, MnoeAppInstances, DASHBOARD_CONFIG) ->
  'ngInject'

  #====================================
  # Select Box
  #====================================
  $scope.selectBox = selectBox = {
    isClosed: true
    isShown: false
    user: MnoeCurrentUser.user
    organization: ''
    isOrganizationManagementEnabled: DASHBOARD_CONFIG.organization_management?.enabled
  }

  # Switch to another company
  selectBox.changeTo = (organization) ->
    # Do nothing if click on the already selected company
    return if organization.id == MnoeOrganizations.selectedId
    # Switch to selected company
    MnoeAppInstances.emptyAppInstances()
    MnoeAppInstances.clearCache()
    MnoeOrganizations.get(organization.id)
    selectBox.close()

  selectOrganization = ->
    selectBox.organization = _.find(MnoeCurrentUser.user.organizations, { id: MnoeOrganizations.selectedId })

  # Toggle the select box
  selectBox.toggle = ->
    selectBox.isClosed = !selectBox.isClosed

  # Close the select box
  selectBox.close = ->
    selectBox.isClosed = true

  #====================================
  # Create Company Modal
  #====================================
  selectBox.openCreateCompanyModal = ->
    modalInstance = $uibModal.open(
      templateUrl: 'app/components/dashboard-company-selectbox/modals/create-company.html'
      controller: 'CreateCompanyModalCtrl'
      size: 'lg'
      windowClass: 'inverse'
      backdrop: 'static'
    )
    modalInstance.result.then(
      (organization) ->
        selectBox.changeTo(organization)
        if DASHBOARD_CONFIG.onboarding_wizard?.enabled
          $state.go('onboarding.step1')
        else
          $state.go('home.impac')
    )

  #====================================
  # Post-Initialization
  #====================================
  $scope.$watch MnoeOrganizations.getSelectedId, (val) ->
    if val?
      selectOrganization()

angular.module 'mnoEnterpriseAngular'
  .directive('dashboardCompanySelectbox', ->
    return {
      restrict: 'EA'
      controller: DashboardCompanySelectboxCtrl
      templateUrl: 'app/components/dashboard-company-selectbox/dashboard-company-selectbox.html',
    }
  )
