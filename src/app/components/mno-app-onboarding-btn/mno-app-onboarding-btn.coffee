angular.module 'mnoEnterpriseAngular'
  .component('mnoAppOnboardingBtn', {
    bindings: {
      appInstance: '='
    },
    templateUrl: 'app/components/mno-app-onboarding-btn/mno-app-onboarding-btn.html',
    controller: ($q, $state, $window, $uibModal, toastr, MnoeMarketplace, MnoeCurrentUser, MnoeOrganizations, MnoeAppInstances) ->
      ctrl = this

      ctrl.isLoadingAppInstances = true

      #====================================
      # App Launch
      #====================================
      ctrl.launchAppInstance = ->
        $window.location.href = MnoeAppInstances.oAuthConnectPath(ctrl.appInstance)
        return true

      #====================================
      # App Connect modal
      #====================================
      ctrl.connectAppInstance = ->
        switch ctrl.appInstance.app_nid
          when "xero" then modalInfo = {
            template: "app/views/apps/modals/app-connect-modal-xero.html",
            controller: 'DashboardAppConnectXeroModalCtrl'
          }
          when "myob" then modalInfo = {
            template: "app/views/apps/modals/app-connect-modal-myob.html",
            controller: 'DashboardAppConnectMyobModalCtrl'
          }
          else ctrl.launchAppInstance()

        $uibModal.open(
          templateUrl: modalInfo.template
          controller: modalInfo.controller
          resolve:
            app: ctrl.appInstance
        )

      # Return the different status of the app regarding its installation
      # - INSTALLABLE:                        The app may be installed
      # - INSTALLED_CONNECT/INSTALLED_LAUNCH: The app is already installed, and cannot be multi instantiated
      # - CONFLICT:                           Another app, with a common subcategory that is not multi-instantiable has already been installed
      appInstallationStatus = ->
        if ctrl.conflictingApp
          "CONFLICT"
        else
          if ctrl.appInstance.app_nid != 'office-365' && ctrl.appInstance.stack == 'connector' && !ctrl.appInstance.oauth_keys_valid
            "INSTALLED_CONNECT"
          else
            "INSTALLED_LAUNCH"

      #====================================
      # Initialize
      #====================================
      ctrl.init = ->
        ctrl.isLoadingAppInstances = true

        # Retrieve the apps and the app instances in order to retrieve the current app, and its conflicting status
        # with the current installed app instances
        $q.all(
          marketplace: MnoeMarketplace.getApps(),
          appInstances: MnoeAppInstances.getAppInstances()
        ).then(
          (response) ->
            apps = response.marketplace.apps
            appInstances = response.appInstances

            # Find the corresponding app
            ctrl.app = _.find(apps, {nid: ctrl.appInstance.app_nid})

            # Get the list of installed apps from the list of instances
            nids = _.compact(_.map(appInstances, (a) -> a.app_nid))
            installedApps = _.filter(apps, (a) -> a.nid in nids)

            # Find a conflicting app with the current app based on the subcategories
            # If there is already an installed app, with a common subcategory with the app that is not multi_instantiable
            # We keep that app, as a conflictingApp, to explain why the app cannot be installed.
            if ctrl.app.subcategories
              # retrieve the subcategories names
              names = _.map(ctrl.app.subcategories, 'name')

              ctrl.conflictingApp = _.find(installedApps, (app) ->
                _.find(app.subcategories, (subCategory) ->
                  not subCategory.multi_instantiable and subCategory.name in names
                )
              )

            ctrl.appInstance.status = appInstallationStatus()

            ctrl.isLoadingAppInstances = false
        )

      ctrl.init()

      return
  }
)
