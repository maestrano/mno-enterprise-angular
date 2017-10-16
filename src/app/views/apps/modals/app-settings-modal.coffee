
angular.module 'mnoEnterpriseAngular'
  .controller('DashboardAppSettingsModalCtrl', ($scope, MnoConfirm, MnoeOrganizations, $uibModalInstance, MnoeAppInstances, Utilities, app, $window, ImpacMainSvc, $translate, toastr)->

    $scope.modal ||= {}
    $scope.app = app
    $scope.sentence = "Please proceed to the deletion of my app and all data it contains"
    $scope.organization_uid = ImpacMainSvc.config.currentOrganization.uid
    $scope.isDisconnecting = false
    $scope.syncs = {
      list: []
      sort: 'updated_at.desc'
      baseSize: 4
      page: 1
      loading: false
      pageChangedCb: (page) ->
        $scope.syncs.page = page
        $scope.loadSyncs()
    }
    $scope.mnoSortableTableFields = [{ header: 'Date', attr: 'updated_at'}, { header: 'Status', attr: 'status'}, { header: 'Message', attr: 'message'}]

    this.$onInit = ->
      $scope.loadSyncs()

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
      MnoeAppInstances.isAddOnWithOrg(app) &&
      app.addon_organization.has_account_linked

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
      $scope.syncs.loading = true
      params = { size: $scope.syncs.baseSize, page: $scope.syncs.page, sort: $scope.syncs.sort }
      MnoeAppInstances.getSyncs($scope.app, params)
        .then((response) ->
          $scope.syncs.list = _.map(response.data, 'attributes')
          $scope.syncs.totalItems = response.headers('x-total-count')
          $scope.syncs.loading = false
        )

    $scope.disconnect = ->
      $scope.isDisconnecting = true
      MnoeAppInstances.disconnect(app)
        .then((response) ->
          app.addon_organization.has_account_linked = false
          app.addon_organization.sync_enabled = false
          $uibModalInstance.close()
          toastr.success("Your application has been disconnected")
          $scope.isDisconnecting = false
        )

    $scope.sortableTableServerPipe = (tableState)->
      $scope.syncs.sort = updateTableSort(tableState.sort)
      $scope.loadSyncs()

    updateTableSort = (sortState = {}) ->
      sort = $scope.syncs.sort
      if sortState.predicate
        sort = sortState.predicate
        if sortState.reverse
          sort += ".desc"
        else
          sort += ".asc"
      return sort

    $scope.selectHistory = ->
      $scope.isLeftFooterButtonShown = true
      $scope.selectedTab = 0
      $scope.textForFooterButton = "Synchronize"

    $scope.selectEntities = ->
      $scope.isLeftFooterButtonShown = true
      $scope.selectedTab = 2
      $scope.textForFooterButton = "Update"

    $scope.selectData = ->
      $scope.isLeftFooterButtonShown = false

    $scope.callToAction = ->
      switch $scope.selectedTab
        when 0
          MnoeAppInstances.sync($scope.app)
          toastr.success("The sync with Neto has started")

    return

  )
