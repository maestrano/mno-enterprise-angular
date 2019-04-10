angular.module 'mnoEnterpriseAngular'
  .controller('DashboardCompanyCtrl',
    ($scope, $state, MnoeOrganizations, MnoeTeams, MnoeConfig) ->
      vm = @
      #====================================
      # Pre-Initialization
      #====================================
      vm.isLoading = true
      vm.payment_enabled = MnoeConfig.isPaymentEnabled()

      #====================================
      # Scope Management
      #====================================
      vm.initialize = ->
        vm.isLoading = false
      # On refreshing the page it should stay on the same tab
        if vm.isBillingShown()
          vm.activeTab = $state.current.startTab[0]
        else
          vm.activeTab = $state.current.startTab[1]

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
