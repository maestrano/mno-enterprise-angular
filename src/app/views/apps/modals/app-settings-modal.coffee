
angular.module 'mnoEnterpriseAngular'
  .controller('DashboardAppSettingsModalCtrl', ($scope, MnoConfirm, MnoeOrganizations, $uibModalInstance, MnoeAppInstances, Utilities, app, $window, ImpacMainSvc, $translate)->

    $scope.modal ||= {}
    $scope.app = app
    $scope.sentence = "Please proceed to the deletion of my app and all data it contains"
    $scope.organization_uid = ImpacMainSvc.config.currentOrganization.uid

    # ----------------------------------------------------------
    # Initialize deletion sentence
    # ----------------------------------------------------------
    $translate('mno_enterprise.templates.impac.dock.settings.deletion_sentence').then(
      (result) ->
        $scope.sentence = result
    )

    # ----------------------------------------------------------
    # Permissions helper
    # ----------------------------------------------------------

    $scope.helper = {}
    $scope.helper.canDeleteApp = ->
      MnoeOrganizations.can.destroy.appInstance()

    $scope.modal.close = ->
      $uibModalInstance.close()

    #====================================
    # App deletion modal
    #====================================
    $scope.deleteApp = ->
      $scope.modal.loading = true
      MnoeAppInstances.terminate($scope.app.id).then(
        ->
          $scope.modal.errors = null
          $uibModalInstance.close()
        (error) ->
          $scope.modal.errors = Utilities.processRailsError(error)
      ).finally(-> $scope.modal.loading = false)

    $scope.helper.isDataSyncShown = (app) ->
      app.stack == 'connector' && app.oauth_keys_valid

    $scope.helper.isDataDisconnectShown = (app) ->
      app.stack == 'connector' && app.oauth_keys_valid

    $scope.helper.dataSyncPath = (app) ->
      "/mnoe/webhook/oauth/#{app.uid}/sync"

    $scope.helper.companyName = (app) ->
      if app.stack == 'connector' && app.oauth_keys_valid && app.oauth_company_name
        return app.oauth_company_name
      false

    $scope.helper.isAddOnSettingShown = (app) ->
      app.add_on

    $scope.helper.addOnSettingLauch = (app) ->
      $window.open("/mnoe/launch/#{app.uid}?settings=true", '_blank')
      return true

    $scope.helper.dataDisconnectClick = (app) ->

      modalOptions =
        closeButtonText: 'Cancel'
        actionButtonText: 'Disconnect app'
        headerText: "Disconnect #{app.app_name}?"
        bodyText: "Are you sure you want to disconnect #{app.app_name} and Maestrano?"

      MnoConfirm.showModal(modalOptions).then(
        ->
          MnoeAppInstances.clearCache()
          $window.location.href = "/mnoe/webhook/oauth/#{app.uid}/disconnect"
      )
  )
