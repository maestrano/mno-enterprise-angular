
#============================================
#
#============================================
DashboardCompanySelectboxCtrl = ($scope, $location, $stateParams, $cookies, $sce, $uibModal,
  MnoeCurrentUser, MnoeOrganizations, ModalSvc) ->

    #====================================
    # Select Box
    #====================================
    $scope.selectBox = selectBox = {
      isClosed: true
      isShown: false
      user: MnoeCurrentUser.user
    }

    selectBox.changeTo = (organization) ->
      selectBox.organization = organization
      MnoeOrganizations.get(organization.id)
      selectBox.close()

    selectBox.getOrganization = () ->
      _.find(MnoeCurrentUser.user.organizations, { id: MnoeOrganizations.selectedId })

    selectBox.toggle = ->
      selectBox.isClosed = !selectBox.isClosed

    selectBox.close = ->
      selectBox.isClosed = true

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
