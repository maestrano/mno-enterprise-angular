DashboardMenuCtrl = ($scope, MnoeCurrentUser) ->
  'ngInject'

  MnoeCurrentUser.get().then(
    (success) ->
      self.current_user_role = MnoeCurrentUser.user.organizations[0].current_user_role

    $scope.isAdminRole = ->
      self.current_user_role == 'Super Admin' || self.current_user_role == 'Admin'
  )

#============================================
# Dashboard Menu
#============================================
angular.module 'mnoEnterpriseAngular'
  .directive('dashboardMenu', ->

    return {
      restrict: 'EA'
      templateUrl: 'app/components/dashboard-menu/dashboard-menu.html',
      controller: DashboardMenuCtrl


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
