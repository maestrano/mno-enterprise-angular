angular.module 'mnoEnterpriseAngular'
  .directive('mnoPassword', (MnoErrorsHandler) ->
    return {
      restrict: 'E',
      scope: {
        form: '=',
        data: '=',
        confirm: '=?',
        current: '=?',
        currentText: '@',
        newText: '@',
        confirmText: '@'
      },
      templateUrl: 'app/components/mno-password/mno-password.html',
      link: (scope, element, attrs) ->
        # Init args
        scope.current = false if !scope.current
        scope.confirm = false if !scope.confirm
        scope.errorHandler = MnoErrorsHandler

        scope.password =
          hasEightChars: false
          hasOneNumber: false
          hasOneUpper: false
          hasOneLower: false
          isSamePassword: false
          check: () ->
            # Reset server error on change
            scope.password.resetServerErrors()

            scope.password.hasEightChars = scope.data.password? && (scope.data.password.length >= 8)
            scope.password.hasOneNumber = false
            scope.password.hasOneUpper = false
            scope.password.hasOneLower = false

            if angular.isString(scope.data.password)
              _.forEach(scope.data.password.split(""), (letter) ->
                scope.password.hasOneNumber = true if Number.isInteger(parseInt(letter))
                scope.password.hasOneUpper = true if (letter == letter.toUpperCase() && letter != letter.toLowerCase() && !parseInt(letter))
                scope.password.hasOneLower = true if (letter == letter.toLowerCase() && letter != letter.toUpperCase() && !parseInt(letter))
              )

              passwordValidity = scope.password.hasEightChars && scope.password.hasOneNumber && scope.password.hasOneUpper && scope.password.hasOneLower
              scope.form.password.$setValidity("password", passwordValidity)

            if scope.confirm
              # Verify that the new password and its confirmation are the same
              scope.password.isSamePassword = (!!scope.data.password && !!scope.data.password_confirmation && scope.data.password == scope.data.password_confirmation)
              scope.form.password_confirmation.$setValidity("password_confirmation", scope.password.isSamePassword)

          resetServerErrors: () ->
            MnoErrorsHandler.resetErrors(scope.form)
    }
  )
