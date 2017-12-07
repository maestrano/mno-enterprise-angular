#============================================
# Dashboard Menu
#============================================
angular.module 'mnoEnterpriseAngular'
  .directive('dashboardMenu', ->

    return {
      restrict: 'EA'
      templateUrl: 'app/components/dashboard-menu/dashboard-menu.html',

      controller: ($scope, MnoeOrganizations, ImpacConfigSvc, DOCK_CONFIG, ORGANIZATION_MANAGEMENT, MARKETPLACE_CONFIG, TASKS_CONFIG) ->
        $scope.isDockEnabled = DOCK_CONFIG.enabled
        $scope.isOrganizationManagementEnabled = ORGANIZATION_MANAGEMENT.enabled
        $scope.isMarketplaceEnabled = MARKETPLACE_CONFIG.enabled
        $scope.isTasksEnabled = TASKS_CONFIG.enabled

        $scope.$watch(MnoeOrganizations.getSelectedId, (newValue) ->
          ImpacConfigSvc.getOrganizations().then(
            (response) ->
              selectedOrg = _.find(response.organizations, { id: parseInt(newValue) })
              $scope.isImpacAvailable = selectedOrg.acl.related.impac.show
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
