#============================================
# Dashboard Menu
#============================================
angular.module 'mnoEnterpriseAngular'
  .directive('dashboardMenu', ->

    return {
      restrict: 'EA'
      templateUrl: 'app/components/dashboard-menu/dashboard-menu.html',

      controller: ($scope, MnoeCurrentUser, MnoeOrganizations, DASHBOARD_CONFIG) ->
        $scope.isDockEnabled = DASHBOARD_CONFIG.dock?.enabled
        $scope.isOrganizationManagementEnabled = DASHBOARD_CONFIG.organization_management?.enabled
        $scope.isMarketplaceEnabled = DASHBOARD_CONFIG.marketplace.enabled

        $scope.$watch(MnoeOrganizations.getSelectedId, (newValue) ->
          # Impac! is displayed only to admin and super admin
          MnoeCurrentUser.get().then(
            (response) ->
              selectedOrg = _.find(response.organizations, {id: newValue})
              $scope.isAdmin = MnoeOrganizations.role.atLeastAdmin(selectedOrg.current_user_role)
          ) if newValue?
        )

        return

      # We need to manually close the collapse menu as we actually stay on the same page
      link: (scope, elem, attrs) ->
        elem.find(".menu").on("mouseenter", ->
          angular.element(this).stop()
          angular.element(this).find(".brand-logo").addClass('expanded')
          angular.element(this).find(".dashboard-button").find(".content").css("display", "block")
          angular.element(this).animate({width:275}, 150)
        )
        elem.find(".menu").on("mouseleave", ->
          angular.element(this).stop()
          angular.element(this).find(".brand-logo").removeClass('expanded')
          angular.element(this).find(".dashboard-button").find(".content").css("display", "none")
          angular.element(this).animate({width:80}, 150)
        )
    }
)
