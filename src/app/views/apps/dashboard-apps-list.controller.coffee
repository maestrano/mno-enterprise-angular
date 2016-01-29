angular.module 'mnoEnterpriseAngular'
  .controller('DashboardAppsListCtrl',
    ($scope, $interval, $q, $stateParams, $window, $uibModal, MnoConfirm, MnoeOrganizations, MnoeAppInstances) ->

      #====================================
      # Pre-Initialization
      #====================================
      $scope.blink = { value: 'neutral' }
      $scope.loading = true
      $scope.originalApps = []

      $scope.apps = []
      $scope.isLoading = true
      $scope.displayOptions = {}

      #====================================
      # Scope Management
      #====================================

      # ----------------------------------------------------------
      # Permissions helper
      # ----------------------------------------------------------
      $scope.helper = {}
      $scope.helper.displayCogwheel = ->
        MnoeOrganizations.can.update.appInstance()

      $scope.helper.canRenameApp = ->
        MnoeOrganizations.can.update.appInstance()

      $scope.helper.canDeleteApp = ->
        MnoeOrganizations.can.destroy.appInstance()

      $scope.helper.isDataSyncShown = (instance) ->
        instance.stack == 'connector' && instance.oauth_keys_valid

      $scope.helper.dataSyncPath = (instance) ->
        "/mnoe/webhook/oauth/#{instance.uid}/sync"

      $scope.helper.isDataDisconnectShown = (instance) ->
        instance.stack == 'connector' && instance.oauth_keys_valid

      $scope.helper.dataDisconnectClick = (instance) ->
        modalOptions =
          closeButtonText: 'Cancel'
          actionButtonText: 'Delete app'
          headerText: 'Delete ' + instance.app_name + '?'
          bodyText: 'Are you sure you want to delete this app?'

        MnoConfirm.showModal(modalOptions).then(
          ->
            $window.location.href = "/mnoe/webhook/oauth/#{instance.uid}/disconnect"
        )

      $scope.helper.appActionUrl = (instance) ->
        "/mnoe/launch/#{instance.uid}"

      $scope.helper.companyName = (instance) ->
        if instance.stack == 'connector' && instance.oauth_keys_valid && instance.oauth_company_name
          return instance.oauth_company_name
        false

      $scope.helper.connectorVersion = (instance) ->
        if instance.stack == 'connector' && instance.oauth_keys_valid && instance.connectorVersion
          return capitalize(instance.connectorVersion)
        false

      $scope.helper.isOauthConnectBtnShown = (instance) ->
        instance.app_nid != 'office-365' &&
        instance.stack == 'connector' &&
        !instance.oauth_keys_valid

      $scope.helper.oAuthConnectPath = (instance)->
        "/mnoe/webhook/oauth/#{instance.uid}/authorize"

      $scope.updateAppName = (app) ->
        origApp = $scope.originalApps["app_instance_#{app.id}"]
        if app.name.length == 0
          app.name = origApp.name
        else
          MnoeAppInstances.update(app).then(
            ->
              origApp.name = app.name
            ->
              app.name = origApp.name
          )

      #====================================
      # App deletion modal
      #====================================
      $scope.openAppDeletionModal = (app) ->
        modalInstance = $uibModal.open(
          templateUrl: 'app/views/apps/modals/app-deletion-modal.html'
          controller: 'AppDeletionModalCtrl'
          resolve:
            app: ->
              app
        )

      #====================================
      # Post-Initialization
      #====================================
      $scope.$watch MnoeOrganizations.getSelectedId, (val) ->
        if val?
          $scope.isLoading = true
          MnoeAppInstances.getAppInstances().then(
            (response) ->
              $scope.isLoading = false
              $scope.apps = response
          )
  )
