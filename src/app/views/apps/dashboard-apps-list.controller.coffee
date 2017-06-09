angular.module 'mnoEnterpriseAngular'
  .controller('DashboardAppsListCtrl',
    ($scope, $interval, $q, $stateParams, $window, $uibModal, MnoConfirm, MnoeOrganizations, MnoeAppInstances, MARKETPLACE_CONFIG) ->

      #====================================
      # Pre-Initialization
      #====================================
      $scope.blink = { value: 'neutral' }
      $scope.loading = true
      $scope.originalApps = []

      $scope.apps = []
      $scope.isLoading = true
      $scope.displayOptions = {}

      $scope.isMarketplaceEnabled = MARKETPLACE_CONFIG.enabled

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
          actionButtonText: 'Disconnect app'
          headerText: "Disconnect #{instance.app_name}?"
          bodyText: "Are you sure you want to disconnect #{instance.app_name} and Maestrano?"

        MnoConfirm.showModal(modalOptions).then(
          ->
            MnoeAppInstances.clearCache()
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
        MnoeAppInstances.clearCache()
        $window.location.href = "/mnoe/webhook/oauth/#{instance.uid}/authorize"

      $scope.helper.isLaunchHidden = (instance) ->
        instance.status == 'terminating' ||
        instance.status == 'terminated' ||
        $scope.helper.isOauthConnectBtnShown(instance) ||
        $scope.helper.isNewOfficeApp(instance)

      $scope.helper.isNewOfficeApp = (instance) ->
        instance.stack == 'connector' && instance.appNid == 'office-365' && (moment(instance.createdAt) > moment().subtract({minutes:5}))

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
            ->
              $scope.isLoading = false
              $scope.apps = MnoeAppInstances.appInstances
          )
  )
