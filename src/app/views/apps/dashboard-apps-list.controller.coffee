angular.module 'mnoEnterpriseAngular'
  .controller('DashboardAppsListCtrl',
    ($scope, $interval, $q, $stateParams, $uibModal, MnoConfirm, MnoeOrganizations, DashboardAppsDocument, DashboardAppInstance, AppsListHelper, DhbOrganizationSvc) ->
      $scope.blink = { value: 'neutral' }

      #====================================
      # Pre-Initialization
      #====================================
      $scope.loading = true
      $scope.originalApps = []

      $scope.apps = {}
      $scope.apps.appInstances = null
      $scope.apps.isLoading = true

      #====================================
      # Scope Management
      #====================================
      init = () ->
        # Scope initialization
        $scope.displayOptions = {}
        $scope.helper = {}
        $scope.appsListHelper = AppsListHelper.new()
        can = DhbOrganizationSvc.can
        angular.copy(DashboardAppsDocument.data,$scope.originalApps)
        $scope.loading = false

        # ----------------------------------------------------------
        # Permissions helper
        # ----------------------------------------------------------
        $scope.helper.displayCogwheel = ->
          can.update.appInstance()

        $scope.helper.canRestartApp = ->
          can.update.appInstance()

        $scope.helper.canRenameApp = ->
          can.update.appInstance()

        $scope.helper.canDeleteApp = ->
          can.destroy.appInstance()

        $scope.helper.canChangePlanApp = (app)->
          app.stack == 'cube' && can.update.appInstance()

        $scope.helper.displayBootstrapWizard = ->
          can.update.appInstance()

        $scope.apps = DashboardAppsDocument.data

        # ----------------------------------------------------------
        # Restart app
        # ----------------------------------------------------------
        $scope.restartApp = { loading: false }
        $scope.restartApp.perform = (id) ->
          $scope.restartApp.loading = true
          DashboardAppInstance.restart(id).then(
            (success) ->
              $scope.restartApp.loading = false
            (error) ->
              $scope.restartApp.loading = false
          )

        $scope.updateAppName = (app) ->
          origApp = $scope.originalApps["app_instance_#{app.id}"]
          if app.name.length == 0
            app.name = origApp.name
          else
            DashboardAppInstance.updateName(app.id,app.name).then(
              (->)
                origApp.name = app.name
              , ->
                app.name = origApp.name
            )

      # ----------------------------------------------------------
      # Little trick to create 'blinking' effect
      # (used for the status of the apps)
      # ----------------------------------------------------------
      blink = ->
        if $scope.blink.value == '' then $scope.blink.value = 'neutral'
        else $scope.blink.value = ''
      $interval((-> blink()),500)

      $scope.shouldBlink = (status) ->
        _.contains([
          'starting',
          'restarting',
          'stopping',
          'terminating',
          'upgrading',
          'downgrading',
        ],status)

      #====================================
      # App deletion modal
      #====================================
      $scope.openAppDeletionModal = (app) ->
        modalDefaults =
          templateUrl: 'app/views/dashboard-apps-list/modals/app-deletion-modal.html'

        modalInstance = $uibModal.open(
          templateUrl: 'app/views/dashboard-apps-list/modals/app-deletion-modal.html'
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
          $scope.apps.isLoading = true
          MnoeOrganizations.getAppInstances().then(
            (response) ->
              console.log "in DashboardAppsListCtrl getAppInstances", response
              $scope.apps.isLoading = false
              $scope.apps.appInstances = response
          )

  )
