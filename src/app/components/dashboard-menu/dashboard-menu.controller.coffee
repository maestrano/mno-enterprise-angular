#============================================
# Dashboard Menu
#============================================
angular.module 'mnoEnterpriseAngular'
  .directive('dashboardMenu', ->

    return {
      restrict: 'EA'
      templateUrl: 'app/components/dashboard-menu/dashboard-menu.html',

      controller: ($scope, $state, MnoeOrganizations, DOCK_CONFIG) ->
        $scope.isLoading = true

        $scope.$watch(MnoeOrganizations.getSelected, (newValue, oldValue) ->
          if newValue?
            # Impac! is displayed only to admin and super admin
            $scope.isAdmin = MnoeOrganizations.role.isAtLeastAdmin()
            $scope.isDockEnabled = DOCK_CONFIG.enabled
            $scope.isLoading = false

            $state.go('home.apps') unless $scope.isAdmin
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
