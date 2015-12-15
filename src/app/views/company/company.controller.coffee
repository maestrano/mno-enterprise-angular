angular.module 'mnoEnterpriseAngular'
  .controller('DashboardCompanyCtrl',
    ($scope, DhbOrganizationSvc) ->
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
          DhbOrganizationSvc.user.isSuperAdmin() || DhbOrganizationSvc.user.isAdmin())

      vm.isBillingShown = ->
        DhbOrganizationSvc.user.isSuperAdmin()

      vm.isSettingsShown = ->
        DhbOrganizationSvc.user.isSuperAdmin()

      #====================================
      # Post-Initialization
      #====================================
      $scope.$watch DhbOrganizationSvc.getId, (val) ->
        vm.isLoading = true
        if val?
          DhbOrganizationSvc.load().then (organization)->
            vm.initialize()

      return
  )
