angular.module 'mnoEnterpriseAngular'
  .service 'MnoSessionTimeout', ($q, $timeout, MnoConfirm, MnoeCurrentUser) ->
    _self = @

    timer = null

    @resetTimer = ->
      # console.debug("Timeout Reset")
      _self.cancelTimer()
      timer = $timeout(showTimeoutModal, 60*1000 -10)

    @cancelTimer = ->
      # console.debug("Timeout Cancel")
      $timeout.cancel(timer)

    showTimeoutModal = ->
      console.debug("Timeout finished!")
      modalOptions =
        closeButtonText: 'Log Off'
        actionButtonText: 'Staay Logged In'
        headerText: 'Session Timeout'
        bodyText: 'You are being logged off due to inactivity. Please choose to stay signed in or to logoff. Otherwise, you will be logged off automatically'
        actionCb: () ->
          MnoeCurrentUser.get().then(
            (response) -> _self.resetTimer()
          )
      MnoConfirm.showModal(modalOptions)

    return @
