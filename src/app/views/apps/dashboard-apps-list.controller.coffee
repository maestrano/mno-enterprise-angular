angular.module 'mnoEnterpriseAngular'
  .controller('DashboardAppsListCtrl',
    ($scope, $interval, $q, $stateParams, $uibModal, MnoConfirm, MnoeOrganizations, MnoeAppInstances) ->

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

      $scope.helper.canChangePlanApp = (app)->
        app.stack == 'cube' && MnoeOrganizations.can.update.appInstance()

      $scope.helper.displayBootstrapWizard = ->
        MnoeOrganizations.can.update.appInstance()

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
