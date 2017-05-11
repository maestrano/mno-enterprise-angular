angular.module 'mnoEnterpriseAngular'
  .directive('connectApplicationsWizard',->
    return {
      restrict: 'EA'
      templateUrl: 'app/components/connect-applications-wizard/connect-applications-wizard.html',
      scope: {
        areAppsPurchased: "="
        areAppsReady: "="
      }

      controller: ($scope, MnoeAppInstances, $window, $uibModal, MnoeOrganizations) ->

        $scope.areAppsReady = false
        # Once the apps selected in the onboarding marketplace are added to the organization
        # it will retreive the app instances to connect them.
        $scope.$watch('areAppsPurchased', (finishAddingApps)->
          $scope.areAppsReady = false
          if finishAddingApps
            MnoeAppInstances.clearCache()
            MnoeAppInstances.getAppInstances().then( ->
              $scope.apps = MnoeAppInstances.appInstances
              $scope.areAppsReady = true
            )
        , true)

        $scope.isLaunchHidden = (app) ->
          app.status == 'terminating' ||
          app.status == 'terminated' ||
          $scope.isOauthConnectBtnShown(app) ||
          $scope.isNewOfficeApp(app)
      
        $scope.isOauthConnectBtnShown = (instance) ->
          instance.app_nid != 'office-365' &&
          instance.stack == 'connector' &&
          !instance.oauth_keys_valid

        $scope.isNewOfficeApp = (instance) ->
          instance.stack == 'connector' && instance.appNid == 'office-365' && (moment(instance.createdAt) > moment().subtract({minutes:5}))

        $scope.launchApp = (app) ->
          $window.open("/mnoe/launch/#{app.uid}", '_blank')

        $scope.oAuthConnectPath = (instance)->
          MnoeAppInstances.clearCache()
          $window.location.href = "/mnoe/webhook/oauth/#{instance.uid}/authorize"
        
        #====================================
        # App Connect modal
        #====================================
        $scope.showConnectModal = (app) ->
          switch app.app_nid
            when "xero" then modalInfo = {
              template: "app/views/apps/modals/app-connect-modal-xero.html",
              controller: 'DashboardAppConnectXeroModalCtrl'
            }
            when "myob" then modalInfo = {
              template: "app/views/apps/modals/app-connect-modal-myob.html",
              controller: 'DashboardAppConnectMyobModalCtrl'
            }
            else $scope.oAuthConnectPath(app)

          modalInstance = $uibModal.open(
            templateUrl: modalInfo.template
            controller: modalInfo.controller
            resolve:
              app: ->
                app
          )

        return
    }
  )
