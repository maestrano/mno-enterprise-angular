
angular.module 'mnoEnterpriseAngular'
  .controller('DashboardAppSettingsModalCtrl', ($scope, MnoConfirm, MnoeOrganizations, $uibModalInstance, MnoeAppInstances, Utilities, app, $window, ImpacMainSvc, toastr, $filter, $translate, AppSettingsHelper)->

    $scope.modal ||= {}
    $scope.app = app
    $scope.sentence = "Please proceed to the deletion of my app and all data it contains"
    $scope.organization_uid = ImpacMainSvc.config.currentOrganization.uid
    $scope.isDisconnecting = false
    $scope.syncs = {
      list: []
      sort: '-updated_at'
      baseSize: 5
      page: 1
      loading: false
      pageChangedCb: (nbItems, page) ->
        $scope.syncs.baseSize = nbItems
        $scope.syncs.page = page
        $scope.loadSyncs()
    }
    $scope.idMaps = {
      entityName: "All"
      list: []
      sort: 'name'
      baseSize: 5
      page: 1
      loading: false
      pageChangedCb: (nbItems, page) ->
        $scope.idMaps.baseSize = nbItems
        $scope.idMaps.page = page
        $scope.loadIdMaps($scope.idMaps.externalNames)
    }
    $translate([
      'mno_enterprise.templates.impac.dock.settings.sync_list.date',
      'mno_enterprise.templates.impac.dock.settings.sync_list.status',
      'mno_enterprise.templates.impac.dock.settings.sync_list.message',
      'mno_enterprise.templates.impac.dock.settings.id_maps.name',
      'mno_enterprise.templates.impac.dock.settings.id_maps.type',
      'mno_enterprise.templates.impac.dock.settings.id_maps.status',
    ]).then((tls) ->
      $scope.mnoSyncsTableFields = [
        { header: tls['mno_enterprise.templates.impac.dock.settings.sync_list.date'], attr: 'updated_at'},
        { header: tls['mno_enterprise.templates.impac.dock.settings.sync_list.status'], attr: 'status'},
        { header: tls['mno_enterprise.templates.impac.dock.settings.sync_list.message'], attr: 'message'}
      ]
      $scope.mnoIdMapsTableFields = [
        { header: tls['mno_enterprise.templates.impac.dock.settings.id_maps.name'], attr: 'name'},
        { header: tls['mno_enterprise.templates.impac.dock.settings.id_maps.type'], attr: 'external_entity'},
        { header: tls['mno_enterprise.templates.impac.dock.settings.id_maps.status'], attr: 'status'}
      ]
    )

    this.$onInit = ->
      if MnoeAppInstances.isAddOnWithOrg(app)
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
      app.addon_organization.sync_enabled

    $scope.helper.addOnSettingLauch = (app) ->
      AppSettingsHelper.addOnSettingLauch(app)

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
      params = {
        per_page: $scope.syncs.baseSize,
        page: $scope.syncs.page,
        sort: $scope.syncs.sort
      }
      MnoeAppInstances.getSyncs($scope.app, params)
        .then((response) ->
          $scope.syncs.list = _.map(response.data, 'attributes')
          $scope.syncs.totalItems = response.headers('x-total-count')
          $scope.syncs.loading = false
        )

    searchInput = ->
      htmlTemplate = '<input placeholder="search name" ng-model="input" ng-change="changeInput(input)"/>'
      {
        scope:
          input: ''
          changeInput: (input) ->
            if input.length > 2
              $scope.loadIdMaps($scope.idMaps.entityName, input)
        template: htmlTemplate
      }

    optionsForEntities = (data) ->
      htmlTemplate = '<select ng-init="model=types[getIndexFromValue(model, types)]" ng-model="model" ng-change="changeEntity(model)" ng-options="option for option in types"></select>'
      {
        scope:
          model: data[0]
          types: data[1]
          changeEntity: (model) ->
            $scope.loadIdMaps(model)
          getIndexFromValue: (value, array) ->
            _.indexOf(array ,value)

        template: htmlTemplate
      }

    $scope.loadIdMaps = (externalName = 'All', input = null) ->
      $scope.idMaps.loading = true
      $scope.idMaps.entityName = externalName
      params = {
        per_page: $scope.idMaps.baseSize,
        page: $scope.idMaps.page,
        sort: $scope.idMaps.sort
      }
      params['filter[name.like]'] = ('%' + input + '%') if input
      params['filter[external_entity.in]'] = externalName unless externalName == "All"
      MnoeAppInstances.getIdMaps($scope.app, params)
        .then((response) ->
          $scope.mnoIdMapsSubHeaders = [
            {render: searchInput},
            {render: optionsForEntities, data: [$scope.idMaps.entityName, $scope.app.addon_organization.entities_types]},
            {}
          ] unless input
          $scope.idMaps.list = response.data.map (e) ->
            att = e.attributes
            # If the entity has synced both ways (connec_id and external_id are present),
            # we display ⇆. Otherwise, we display ↚ if it failed to sync to the external_app,
            # or ↛ if it failed to sync to Connec
            if att.connec_id
              att.status = if att.external_id then '&#8646;' else '&#8602;'
            else if att.external_id
              att.status = '&#8603;'
            att
          $scope.idMaps.totalItems = response.headers('x-total-count')
          $scope.idMaps.loading = false
        )

    $scope.disconnect = ->
      modalOptions =
        closeButtonText: 'mno_enterprise.templates.impac.dock.settings.disconnect.modal.cancel'
        actionButtonText: 'mno_enterprise.templates.impac.dock.settings.disconnect.modal.action'
        headerText: 'mno_enterprise.templates.impac.dock.settings.disconnect.modal.header'
        headerTextExtraData: {appname: app.app_name}
        bodyText: 'mno_enterprise.templates.impac.dock.settings.disconnect.modal.body'
        bodyTextExtraData: {appname: app.app_name}

      MnoConfirm.showModal(modalOptions).then(
        ->
          $scope.isDisconnecting = false
          MnoeAppInstances.disconnect(app)
            .then((response) ->
              app.addon_organization.has_account_linked = false
              app.addon_organization.sync_enabled = false
              $uibModalInstance.close()
              toastr.success("Your application has been disconnected")
        ).finally(-> $scope.isDisconnecting = false)
      )

    $scope.sortableSyncsServerPipe = (tableState)->
      $scope.syncs.sort = updateTableSort(tableState.sort, $scope.syncs.sort)
      $scope.loadSyncs()

    $scope.sortableIdMapsServerPipe = (tableState)->
      $scope.idMaps.sort = updateTableSort(tableState.sort, $scope.idMaps.sort)
      $scope.loadIdMaps($scope.idMaps.entityName)

    updateTableSort = (sortState = {}, sort) ->
      if sortState.predicate
        sort = sortState.predicate
        sort = "-#{sort}" if sortState.reverse
      return sort

    $scope.syncEnabled = ->
      MnoeAppInstances.isAddOnWithOrg($scope.app) && $scope.app.addon_organization.sync_enabled

    $scope.selectHistory = ->
      $scope.selectedTab = 0

    $scope.selectEntities = ->
      $scope.selectedTab = 2

    $scope.selectData = ->
      $scope.selectedTab = 1

    $scope.syncApp = ->
      MnoeAppInstances.sync($scope.app)
      toastr.success('mno_enterprise.templates.impac.dock.settings.sync_started', {extraData: { appname: $scope.app.name }})

    return

  )
