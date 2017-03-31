angular.module 'mnoEnterpriseAngular'
  .controller('DashboardCompanyCtrl',
    ($scope, MnoeOrganizations, MnoeTeams, MnoeConfig, PAYMENT_CONFIG) ->
      vm = @

      #====================================
      # Pre-Initialization
      #====================================
      vm.isLoading = true
      vm.tabs = {
        billing: false,
        members: false,
        teams: false,
        settings: false
      }
      vm.payment_enabled = not PAYMENT_CONFIG.disabled

      #====================================
      # Scope Management
      #====================================
      vm.initialize = ->
        vm.isLoading = false
        if vm.isBillingShown()
          vm.tabs.billing = true
        else
          vm.tabs.members = true

      vm.isTabSetShown = ->
        !vm.isLoading && (
          MnoeOrganizations.role.isSuperAdmin() || MnoeOrganizations.role.isAdmin())

      vm.isBillingShown = ->
        MnoeOrganizations.role.isSuperAdmin()

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
