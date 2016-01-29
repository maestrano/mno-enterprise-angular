
#============================================
#
#============================================
DashboardCompanySelectboxCtrl = ($scope, $location, $stateParams, $cookies, $sce, $uibModal, MnoeCurrentUser, MnoeOrganizations, ModalSvc) ->
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
  # New Orga Modal
  #====================================
  newOrgModal = ModalSvc.newOrgModal({
    callback: (data) ->
      selectBox.changeTo(data)
  })

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
