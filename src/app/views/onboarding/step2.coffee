angular.module 'mnoEnterpriseAngular'
  .controller 'OnboardingStep2Controller', ($q, $state, $uibModal, MnoeMarketplace, MnoeOrganizations, MnoeAppInstances, DOC_LINKS) ->
    'ngInject'

    vm = this

    MAX_APPS_ONBOARDING = 4

    vm.searchTerm = ''
    vm.isLoading = true

    vm.connecDocUri = DOC_LINKS.connecDoc

    vm.selectedApps = []

    vm.appsFilter = (app) ->
      if vm.selectedCategory then _.contains(app.categories, vm.selectedCategory) else true

    # Select or deselect an app
    vm.toggleApp = (app) ->
      # User cannot add disabled apps (over 4 or conflicting)
      # names = []
      # _.each vm.selectedApps, (selectedApp) ->
      #   _.each selectedApp.subcategories, (subCategory) ->
      #     names.push(subCategory.name)
      #     vm.appInstances.
      # app.conflictingApp = _.each(vm.appInstances, (appInstance) ->
      #   _.find(app.subcategories, (subCategory) ->
      #     not subCategory.multi_instantiable and subCategory.name in names
      #     )
      # )

      app.subcategoryNames = []
      _.each(app.subcategories, (appSubcategory) ->
        app.subcategoryNames.push(appSubcategory.name)
      )
      app.marketplaceApps = _.filter(vm.marketplace.apps, (marketplaceApp) ->
        marketplaceApp != app
      )
      _.each(app.marketplaceApps, (marketplaceApp) ->
        # marketplaceApp.conflictingApp = {}
        _.each(marketplaceApp.subcategories, (marketplaceAppSubCategory) ->
          _.find(app.subcategoryNames, (subcategoryName) ->
            if marketplaceApp != app && !marketplaceAppSubCategory.multi_instantiable && (marketplaceAppSubCategory.name == subcategoryName)
              marketplaceApp.conflictingApp = app
          )
        )
        console.log(marketplaceApp) if marketplaceApp != app
      )
      # vm.marketplaceConflicts = _.each(vm.marketplace.apps, (marketplaceApp) ->
        # console.log(marketplaceApp.conflictingApp)
      # )


      # console.log(subcategoryNames)
      console.log(vm.selectedAppConflict(app))

      return if vm.appSelectDisabled(app)

      app.checked = !app.checked
      if app.checked
        vm.selectedApps.push(app)
      else
        _.remove(vm.selectedApps, app)
      vm.maxAppsSelected = (vm.selectedApps.length == MAX_APPS_ONBOARDING)
      compareSharedEntities(vm.selectedApps)
      return

    vm.selectedAppConflict = (app) ->
      _.find(vm.selectedApps, (selectedApp) ->
        app.conflictingApp == selectedApp
      )

    vm.appSelectDisabled = (app) ->
      (vm.maxAppsSelected && !app.checked) || vm.selectedAppConflict(app) && !app.checked #(app != app.conflictingApp)

    vm.appSelectDisabledTooltipText = (app) ->
      if vm.maxAppsSelected && !app.checked
        'mno_enterprise.templates.onboarding.select_your_app.max_apps_selected_tooltip'
      else if vm.selectedAppConflict(app)
        'mno_enterprise.templates.onboarding.select_your_app.conflicting_app_selected_tooltip'

    compareSharedEntities = (apps) ->
      appEntities = []
      listEntities = []
      # List of entities per app
      _.each(apps, (a) ->
        entities = _.map(a.shared_entities, 'shared_entity_name')
        listEntities = _(listEntities).concat(entities).value()
        appEntities.push({nid: a.nid, logo: a.logo, name: a.name, entities: entities})
      )
      # Build the full list of entities
      listEntities = _.uniq(listEntities)
      vm.appEntities = appEntities
      vm.listEntities = listEntities

    vm.containsEntity = (entities, entity) ->
      return _.includes(entities, entity)

    # ====================================
    # Connect the apps & go to next screen
    # ====================================
    vm.connectApps = () ->
      vm.isConnectingApps = true
      # List of app instances to add and delete
      appsToAdd = _.filter(vm.marketplace.apps, (app) -> app.checked == true && not _.includes(vm.originalAppNids, app.nid))
      appsToDelete = _.filter(vm.marketplace.apps, (app) -> app.checked == false && _.includes(vm.originalAppNids, app.nid))
      appsInstancesToDelete = _.filter(vm.appInstances, (ai) -> _.includes(_.map(appsToDelete, 'nid'), ai.app_nid))

      # Purchase new apps
      promises = _.map(appsToAdd, (app) -> MnoeOrganizations.purchaseApp(app))
      # Terminate old app instances
      promises = _(promises).concat(_.map(appsInstancesToDelete, (ai) -> MnoeAppInstances.terminate(ai.id))).value()
      # Refresh app instances and go to next screen
      $q.all(promises).finally(
        ->
          MnoeAppInstances.refreshAppInstances().then(
            ->
              vm.isConnectingApps = false
              $state.go('onboarding.step3')
          )
      )

    # ====================================
    # App Info modal
    # ====================================
    vm.openInfoModal = (app) ->
      $uibModal.open(
        templateUrl: 'app/views/onboarding/modals/app-infos.html'
        controller: 'MnoAppInfosCtrl'
        controllerAs: 'vm',
        size: 'lg'
        resolve:
          app: app
      )

    $q.all({
      appInstances: MnoeAppInstances.getAppInstances()
      marketplace: MnoeMarketplace.getApps()
    }).then(
      (response) ->
        vm.appInstances = angular.copy(response.appInstances)
        vm.marketplace = angular.copy(response.marketplace.plain())

        # Fetch the already selected apps
        vm.originalAppNids = _.map(vm.appInstances, 'app_nid')

        # Toggle the already selected apps
        _.each(_.filter(vm.marketplace.apps, (app) -> _.includes(vm.originalAppNids, app.nid)), (a) -> vm.toggleApp(a))
    ).finally(-> vm.isLoading = false)

    return
