
angular.module 'mnoEnterpriseAngular'
  .controller('DashboardAppSettingsModalCtrl', ($scope, MnoConfirm, MnoeOrganizations, $uibModalInstance, MnoeAppInstances, Utilities, app, $window, ImpacMainSvc, $translate, toastr)->

    $scope.modal ||= {}
    $scope.app = app
    $scope.sentence = "Please proceed to the deletion of my app and all data it contains"
    $scope.organization_uid = ImpacMainSvc.config.currentOrganization.uid
    $scope.isLoadingSyncs = true
    $scope.isDisconnecting = false
    $scope.syncs = []

    MnoeAppInstances.getSyncs($scope.app)
      .then((response) ->
        for i in [0...response.length]
          $scope.syncs.push response[i].attributes
        $scope.isLoadingSyncs = false
      )

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
      app.add_on &&
      app.organization &&
      app.organization.has_account_linked

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

    $scope.loadSyncs = ->
      $scope.isLoadingSyncs = true
      $scope.syncs = []
      MnoeAppInstances.getSyncs($scope.app)
        .then((response) ->
          for i in [0...response.length]
            $scope.syncs.push response[i].attributes
          $scope.isLoadingSyncs = false
        )

    $scope.disconnect = ->
      $scope.isDisconnecting = true
      MnoeAppInstances.disconnect(app)
        .then((response) ->
          app.organization.has_account_linked = false
          $uibModalInstance.close()
          toastr.success("Your application has been disconnected")
          $scope.isDisconnecting = false
        )

    $scope.switchTab = (indexActive) ->
      activeTab = "tab" + indexActive
      document.getElementById("tab" + indexActive).classList.add("active")
      document.getElementById("head" + indexActive).classList.add("active")
      for i in [0..1]
        document.getElementById("tab" + ((indexActive + i) % 3 + 1)).classList.remove("active")
        document.getElementById("head" + ((indexActive + i) % 3 + 1)).classList.remove("active")
      switch indexActive
        when 1 then $scope.loadSyncs()
        when 2 then $scope.loadSyncs()

    return

  )
