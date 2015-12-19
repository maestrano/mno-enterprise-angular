angular.module 'mnoEnterpriseAngular'
  .controller('DashboardAccountCtrl',
    ($scope, $log, toastr, MnoeCurrentUser, MnoErrorsHandler, CurrentUserSvc, DashboardUser, Miscellaneous, Utilities) ->
      CurrentUserSvc.loadDocument()
      CurrentUserSvc.then ->

        # Scope init
        $scope.countryCodes = Miscellaneous.countryCodes
        $scope.errors = {}
        $scope.success = {}

        # User model init
        $scope.isPersoInfoOpen = true
        userDocument = MnoeCurrentUser.user
        $scope.user = { model: {}, password: {}, loading:false }

        setUserModel = (model) ->
          $scope.user.model = {
            name: model.name
            surname: model.surname
            email: model.email
            company: model.company
            phone: model.phone
            website: model.website
            phone_country_code: model.phone_country_code
          }
        if userDocument.deletion_request
          $scope.user.currentDeletionRequestToken = userDocument.deletion_request.token
        else
          $scope.user.currentDeletionRequestToken = -1

        setUserModel(userDocument)
        userOld = angular.copy($scope.user.model)

        $scope.user.hasChanged = ->
          !(_.isEqual($scope.user.model,userOld))

        $scope.user.cancelChanges = ->
          $scope.user.model = _.clone(userOld)

        $scope.user.update = ->
          $scope.user.loading = true
          CurrentUserSvc.update($scope.user.model).then(
            (userResp) ->
              # Email is not changed straight away - Notify user that new email will need to
              # be confirmed
              if userOld.email == $scope.user.model.email
                $scope.success.user = "Saved!"
              else
                $scope.success.user = """Saved! A confirmation email will be sent to your new email address.
                  You will need to click on the link enclosed in this email in order to validate this new address."""

              displayEmail = $scope.user.model.email
              setUserModel(userResp)

              # Email not changed in backend until confirmation
              # Keep changed email on frontend side to avoid user confusion
              $scope.user.model.email = displayEmail

              userOld = _.clone($scope.user.model)
              $scope.user.loading = false
            ,(error) ->
              $scope.user.loading = false
              $scope.errors.user = Utilities.processRailsError(error)
          )

        # ----------------------------------------------------
        # Password update
        # ----------------------------------------------------
        $scope.isChangePasswordOpen = false

        $scope.user.cancelPassword = ->
          $scope.user.password = {}

        $scope.user.cancelPasswordEnabled = ->
          $scope.user.password.current_password ||
          $scope.user.password.password ||
          $scope.user.password.password_confirmation

        $scope.user.updatePassword = (form) ->
          $scope.user.loading = true

          # Reset last error
          MnoErrorsHandler.resetErrors(form)

          # Update the user password
          MnoeCurrentUser.updatePassword($scope.user.password).then(
            ->
              # Success message
              toastr.success('Your password has been changed!')
              # Clear local data
              $scope.user.cancelPassword()
            (error) ->
              toastr.error('An error occured, your password has not been changed.')
              $log.error('Error while updating user: ', error)
              MnoErrorsHandler.processServerError(error, form)
          ).finally( -> $scope.user.loading = false )

        # ----------------------------------------------------
        # Account Deletion
        # ----------------------------------------------------
        $scope.isAccountDeletionOpen = false
        $scope.user.createDeletionRequest = ->
          $scope.user.loading = true
          DashboardUser.deletionRequest().then(
            (success) ->
              $scope.user.loading = false
              $scope.user.currentDeletionRequestToken = success.data.attributes.token
            ,(error) ->
              $scope.user.loading = false
              $scope.errors.deletionReq = Utilities.processRailsError(error)
          )

        $scope.user.cancelDeletionRequest = ->
          if $scope.user.currentDeletionRequestToken
            $scope.user.loading = true
            token = $scope.user.currentDeletionRequestToken
            DashboardUser.cancelDeletionRequest(token).then(
              (success) ->
                $scope.user.loading = false
                $scope.user.currentDeletionRequestToken = -1
              ,(error) ->
                $scope.user.loading = false
                $scope.errors.deletionReq = Utilities.processRailsError(error)
            )

        $scope.user.resendDeletionRequest = ->
          if $scope.user.currentDeletionRequestToken
            $scope.user.loading = true
            token = $scope.user.currentDeletionRequestToken
            DashboardUser.resendDeletionRequest(token).then(
              (success) ->
                $scope.user.loading = false
              ,(error) ->
                $scope.user.loading = false
                $scope.errors.deletionReq = Utilities.processRailsError(error)
            )

        # TODO: nice to have: update the current user info the same way we updateds
        # apps info which will allow to remove the deletion request after 60 minutes
  )
