angular.module 'mnoEnterpriseAngular'
  .component('mnoAppInstallBtn', {
    bindings: {
      app: '=',
      appInstance: '=',
      conflictingApp: '='
    },
    templateUrl: 'app/components/mno-app-install-btn/mno-app-install-btn.html',
    controller: ($state, $window, $uibModal, toastr, MnoeAppInstances, MnoErrorsHandler, MnoeCurrentUser, MnoeOrganizations) ->
      vm = this

      # Return the different status of the app regarding its installation
      # - INSTALLABLE:  The app may be installed
      # - INSTALLED_CONNECT/INSTALLED_LAUNCH: The app is already installed, and cannot be multi instantiated
      # - CONFLICT:     Another app, with a common subcategory that is not multi-instantiable has already been installed
      vm.appInstallationStatus = ->
        if vm.appInstance
          if vm.app.multi_instantiable
            "INSTALLABLE"
          else
            if vm.app.app_nid != 'office-365' && vm.app.stack == 'connector' && !vm.app.oauth_keys_valid
              "INSTALLED_CONNECT"
            else
              "INSTALLED_LAUNCH"
        else
          if vm.conflictingApp
            "CONFLICT"
          else
            "INSTALLABLE"

      vm.canProvisionApp = false

      vm.provisionApp = () ->
        return if !vm.canProvisionApp
        vm.isLoading = true
        MnoeAppInstances.clearCache()

        # Get the authorization status for the current organization
        if MnoeOrganizations.role.atLeastAdmin(vm.user_role)
          purchasePromise = MnoeOrganizations.purchaseApp(vm.app, MnoeOrganizations.selectedId)
        else  # Open a modal to change the organization
          purchasePromise = openChooseOrgaModal().result

        purchasePromise.then(
          ->
            $state.go('home.impac')

            switch vm.app.stack
              when 'cloud' then displayLaunchToastr(vm.app)
              when 'cube' then displayLaunchToastr(vm.app)
              when 'connector'
                if vm.app.nid == 'office-365'  # Office 365 must display 'Launch'
                  displayLaunchToastr(vm.app)
                else
                  displayConnectToastr(vm.app)
          (error) ->
            toastr.error(vm.app.name + " has not been added, please try again.")
            MnoErrorsHandler.processServerError(error)
        ).finally(-> vm.isLoadingButton = false)

      displayLaunchToastr = (app) ->
        toastr.success(
          'mno_enterprise.templates.components.app_install_btn.success_launch_notification_body',
          'mno_enterprise.templates.components.app_install_btn.success_notification_title',
          {extraData: {name: app.name}, timeout: 10000}
        )

      displayConnectToastr = (app) ->
        toastr.success(
          'mno_enterprise.templates.components.app_install_btn.success_connect_notification_body',
          'mno_enterprise.templates.components.app_install_btn.success_notification_title',
          {extraData: {name: app.name}, timeout: 10000}
        )

      openChooseOrgaModal = () ->
        $uibModal.open(
          backdrop: 'static'
          templateUrl: 'app/views/marketplace/modals/choose-orga-modal.html'
          controller: 'MarketplaceChooseOrgaModalCtrl'
          resolve:
            app: vm.app
        )

      #====================================
      # App Launch
      #====================================
      vm.launchAppInstance = ->
        $window.open("/mnoe/launch/#{vm.appInstance.uid}", '_blank')
        return true

      #====================================
      # App Connect modal
      #====================================
      vm.connectAppInstance = ->
        switch vm.appInstance.app_nid
          when "xero" then modalInfo = {
            template: "app/views/apps/modals/app-connect-modal-xero.html",
            controller: 'DashboardAppConnectXeroModalCtrl'
          }
          when "myob" then modalInfo = {
            template: "app/views/apps/modals/app-connect-modal-myob.html",
            controller: 'DashboardAppConnectMyobModalCtrl'
          }
          else vm.launchAppInstance()

        $uibModal.open(
          templateUrl: modalInfo.template
          controller: modalInfo.controller
          resolve:
            app: vm.appInstance
        )

      #====================================
      # Initialize
      #====================================
      vm.init = ->
        MnoeCurrentUser.get().then(
          (response) ->  # Get number of organizations with at least an admin role
            vm.authorizedOrganizations = _.filter(response.organizations, (org) ->
              MnoeOrganizations.role.atLeastAdmin(org.current_user_role)
            )
            vm.canProvisionApp = !_.isEmpty(vm.authorizedOrganizations)
        )

      vm.init()

      return
  }
)
