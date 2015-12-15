
#============================================
#
#============================================
DashboardCompanySelectboxCtrl = ($scope, $location, $stateParams, $cookies, $sce, $uibModal,
  MnoeCurrentUser, MnoeOrganizations, ModalSvc) ->

    #====================================
    # Select Box
    #====================================
    $scope.selectBox = selectBox = {
      form: {}
      isClosed: true
      isShown: false
      user: undefined
      organizations: []
      user = MnoeCurrentUser.user
    }

    selectBox.changeTo = (organization) ->
      selectBox.organization = organization
      MnoeOrganizations.get(organization.id)
      selectBox.close()

    selectBox.toggle = ->
      selectBox.isClosed = !selectBox.isClosed

    selectBox.close = ->
      selectBox.isClosed = true

    selectBox.organizationList = ->
      return _.sortBy(selectBox.organizations, (o) -> o.name)

    selectBox.isCurrentOrganization = (organization) ->
      (organization.id == MnoeOrganizations.selectedId)

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


angular.module 'mnoEnterpriseAngular'
  .directive('dashboardCompanySelectbox', ->
    return {
      restrict: 'EA'
      controller: DashboardCompanySelectboxCtrl
      templateUrl: 'app/components/dashboard-company-selectbox/dashboard-company-selectbox.html',
    }
  )
