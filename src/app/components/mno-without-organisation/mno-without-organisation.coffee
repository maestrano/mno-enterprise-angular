angular.module 'mnoEnterpriseAngular'
  .component('mnoWithoutOrganisation', {
    templateUrl: 'app/components/mno-without-organisation/mno-without-organisation.html',
    controller: ($rootScope, $state, $q, $uibModal, MnoeCurrentUser, MnoeOrganizations, DASHBOARD_CONFIG) ->
      ctrl = this

      ctrl.canCreateOrganisation = DASHBOARD_CONFIG.organization_management?.enabled

      #====================================
      # Create Company Modal
      #====================================
      ctrl.openCreateOrgaModal = ->
        modalInstance = $uibModal.open(
          templateUrl: 'app/components/dashboard-company-selectbox/modals/create-company.html'
          controller: 'CreateCompanyModalCtrl'
          size: 'lg'
          windowClass: 'inverse'
          backdrop: 'static'
        )
        modalInstance.result.then(
          (organization) ->
            # Refresh the state and display the dashboard
            MnoeOrganizations.get(organization.id).then(-> $rootScope.hasNoOrganisations = false)
        )

      MnoeCurrentUser.get().then(
        (response) ->
          ctrl.user = response
      )

      return
  }
)
