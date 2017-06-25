angular.module 'mnoEnterpriseAngular'
  .controller('DashboardCompanyCtrl',
    ($scope, MnoeOrganizations, MnoeTeams, MnoeConfig, DASHBOARD_CONFIG) ->
      vm = @

      #====================================
      # Pre-Initialization
      #====================================
      vm.isLoading = true
      vm.payment_enabled = DASHBOARD_CONFIG.payment?.enabled

      #====================================
      # Scope Management
      #====================================
      vm.initialize = ->
        vm.isLoading = false
        if vm.isBillingShown()
          vm.activeTab = 'billing'
        else
          vm.activeTab = 'members'

      vm.isTabSetShown = ->
        !vm.isLoading && (
          MnoeOrganizations.role.isSuperAdmin() || MnoeOrganizations.role.isAdmin())

      vm.isBillingShown = ->
        MnoeConfig.isBillingEnabled() && MnoeOrganizations.role.isSuperAdmin()

      vm.isSettingsShown = ->
        MnoeOrganizations.role.isSuperAdmin()

      vm.isAuditLogShown = ->
        MnoeConfig.isAuditLogEnabled() && MnoeOrganizations.role.isSuperAdmin()

      #====================================
      # Post-Initialization
      #====================================
      $scope.$watch MnoeOrganizations.getSelectedId, (val) ->
        if val?
          vm.isLoading = true
          MnoeTeams.getTeams(true)

      $scope.$watch MnoeOrganizations.getSelected, (val) ->
        if val?
          vm.initialize()

      return
  )
