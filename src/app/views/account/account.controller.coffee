angular.module 'mnoEnterpriseAngular'
  .controller('DashboardAccountCtrl',
    ($log, $timeout, toastr, MnoeCurrentUser, MnoeUserAccessRequests, MnoErrorsHandler, Miscellaneous, Utilities, I18N_CONFIG, MnoeConfig) ->

      vm = @
      # Scope init
      vm.countryCodes = Miscellaneous.countryCodes
      vm.errors = {}
      vm.success = {}
      vm.isDeveloperSectionEnabled = MnoeConfig.isDeveloperSectionEnabled()
      vm.isUserManagementEnabled = MnoeConfig.isUserManagementEnabled()

      # User model init
      vm.user = { model: {}, password: {}, loading:false }
      userOrig = null

      # Delay the first accordion group opening
      # to avoid a page load glitch
      $timeout (->
        vm.isPersoInfoOpen = true
      ), 250

      vm.user.hasChanged = ->
        !(_.isEqual(vm.user.model, userOrig))

      vm.user.cancelChanges = ->
        vm.user.model = _.clone(userOrig)

      vm.user.update = ->
        vm.user.loading = true
        MnoeCurrentUser.update(vm.user.model).then(
          (userResp) ->
            # Email is not changed straight away - Notify user that new email will need to
            # be confirmed
            if userOrig.email == vm.user.model.email
              vm.success.user = "Saved!"
            else
              vm.success.user = """Saved! A confirmation email will be sent to your new email address.
                You will need to click on the link enclosed in this email in order to validate this new address."""

            displayEmail = vm.user.model.email
            vm.user.model = _.clone(userResp)

            # Email not changed in backend until confirmation
            # Keep changed email on frontend side to avoid user confusion
            vm.user.model.email = displayEmail

            userOrig = _.clone(vm.user.model)
            vm.user.loading = false
          (error) ->
            vm.user.loading = false
            vm.errors.user = Utilities.processRailsError(error)
        )

      # ----------------------------------------------------
      # Password update
      # ----------------------------------------------------
      vm.isChangePasswordOpen = false

      vm.user.cancelPassword = ->
        vm.user.password = {}

      vm.user.cancelPasswordEnabled = ->
        vm.user.password.current_password ||
        vm.user.password.password ||
        vm.user.password.password_confirmation

      vm.user.updatePassword = (form) ->
        vm.user.loading = true

        # Reset last error
        MnoErrorsHandler.resetErrors(form)

        # Update the user password
        MnoeCurrentUser.updatePassword(vm.user.password).then(
          ->
            # Success message
            toastr.success('Your password has been changed!')
            # Clear local data
            vm.user.cancelPassword()
          (error) ->
            toastr.error('An error occured, your password has not been changed.')
            $log.error('Error while updating user: ', error)
            MnoErrorsHandler.processServerError(error, form)
        ).finally( -> vm.user.loading = false )

      # ----------------------------------------------------
      # i18n and l10n section
      # ----------------------------------------------------
      vm.isLocalizationVisible = I18N_CONFIG.enabled
      vm.isLocalizationOpen = false

      # ----------------------------------------------------
      # Developer Section
      # ----------------------------------------------------
      vm.isDevOpen = false
      vm.user.registerDeveloper = ->
        MnoeCurrentUser.registerDeveloper().then(
          (success) ->
            angular.extend(vm.user.model, success)
        )

      vm.isSecretKeyRevealed = false
      vm.user.switchSecretKey = ->
        vm.isSecretKeyRevealed = !vm.isSecretKeyRevealed

      # ----------------------------------------------------
      #  Authorize Admin Access Section
      # ----------------------------------------------------
      vm.isAuthorizeAdminAccessVisible = MnoeConfig.isImpersonationConsentRequired()
      vm.isAuthorizeAdminAccessOpen = false
      vm.access_duration = '24_HOURS'
      if vm.isAuthorizeAdminAccessVisible
        MnoeUserAccessRequests.last_access_request().then(
          (last_access_request) ->
            vm.user.last_access_request = last_access_request
        )

      vm.user.authorizationActive = ->
        vm.user.last_access_request && vm.user.last_access_request.current_status == 'approved'

      vm.user.authorizeAccess = ->
        vm.user.loading = true
        MnoeUserAccessRequests.create({access_duration: vm.access_duration}).then(
          (last_access_request) ->
            vm.user.last_access_request = last_access_request
            # Success message
            toastr.success('mno_enterprise.templates.dashboard.account.authorize.success_toastr')
            (error) ->
              toastr.error('mno_enterprise.templates.dashboard.account.authorize.error_toastr')
              MnoErrorsHandler.processServerError(error)
        ).finally( -> vm.user.loading = false )

      vm.user.revokeAccess = ->
        vm.user.loading = true
        MnoeUserAccessRequests.revoke(vm.user.last_access_request.id).then(
          (last_access_request) ->
            vm.user.last_access_request = last_access_request
            # Success message
            toastr.success('mno_enterprise.templates.dashboard.account.revoke.success_toastr')
            (error) ->
              toastr.error('mno_enterprise.templates.dashboard.account.revoke.error_toastr')
              MnoErrorsHandler.processServerError(error)
          ).finally( -> vm.user.loading = false )


      # ----------------------------------------------------
      # Account Deletion
      # ----------------------------------------------------
      # Removed: cf. git log

      MnoeCurrentUser.get().then(
        (response) ->
          vm.user.model = user = _.clone(MnoeCurrentUser.user)
          userOrig = _.clone(user)

          if user.deletion_request
            vm.user.currentDeletionRequestToken = user.deletion_request.token
          else
            vm.user.currentDeletionRequestToken = -1
      )

      return
  )
