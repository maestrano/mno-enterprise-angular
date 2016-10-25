
#============================================
#
#============================================
DashboardCompanySelectboxCtrl = ($scope, $location, $stateParams, $cookies, $sce, $uibModal, MnoeCurrentUser, MnoeOrganizations, MnoeAppInstances) ->
  'ngInject'

  #====================================
  # Select Box
  #====================================
  $scope.selectBox = selectBox = {
    isClosed: true
    isShown: false
    user: MnoeCurrentUser.user
    organization: ''
  }

  selectBox.changeTo = (organization) ->
    return if organization.id == parseInt(MnoeOrganizations.selectedId)
    MnoeAppInstances.emptyAppInstances()
    MnoeAppInstances.clearCache()
    MnoeOrganizations.get(organization.id)
    selectBox.close()

  selectBox.selectOrganization = ->
    selectBox.organization = _.find(MnoeCurrentUser.user.organizations, { id: parseInt(MnoeOrganizations.selectedId) })

  selectBox.toggle = ->
    selectBox.isClosed = !selectBox.isClosed

  selectBox.close = ->
    selectBox.isClosed = true

  selectBox.createNewOrga = ->
    newOrgModal.open()
    selectBox.close()

  #====================================
  # Create Company Modal
  #====================================
  selectBox.openCreateCompanyModal = ->
    modalInstance = $uibModal.open(
      templateUrl: 'app/components/dashboard-company-selectbox/modals/create-company.html'
      controller: 'CreateCompanyModalCtrl'
      size: 'lg'
      windowClass: 'inverse'
    )
    modalInstance.result.then(
      (selectedItem) ->
        selectBox.changeTo(selectedItem)
    )

  #====================================
  # Post-Initialization
  #====================================
  $scope.$watch MnoeOrganizations.getSelectedId, (val) ->
    if val?
      selectBox.selectOrganization()

  $scope.$watch MnoeOrganizations.getSelected, (val) ->
    if val?
      selectBox.selectOrganization()

angular.module 'mnoEnterpriseAngular'
  .directive('dashboardCompanySelectbox', ->
    return {
      restrict: 'EA'
      controller: DashboardCompanySelectboxCtrl
      templateUrl: 'app/components/dashboard-company-selectbox/dashboard-company-selectbox.html',
    }
  )
