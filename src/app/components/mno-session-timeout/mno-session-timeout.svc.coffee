angular.module 'mnoEnterpriseAngular'
  .service 'MnoSessionTimeout', ($q, $timeout,$uibModal) ->
    _self = @

    timer = null

    @resetTimer = ->
      _self.cancelTimer()
      timer = $timeout(showTimeoutModal, 30*1000 - 10*1000)

    @cancelTimer = ->
      $timeout.cancel(timer)

    showTimeoutModal = ->
      console.debug("Timeout finished!")

      $uibModal.open(
        size: 'md'
        keyboard: false
        backdrop: 'static'
        templateUrl: 'app/components/mno-session-timeout/mno-session-timeout.html'
        controller: modalController)


    modalController = ($scope, $state, $interval, $uibModalInstance, MnoeCurrentUser, toastr) ->
      'ngInject'

      $scope.countdown = 10

      $interval((-> $scope.countdown -= 1),1000, 10)

      $scope.stayLoggedIn = () ->
        $scope.isLoading = true
        MnoeCurrentUser.refresh().then(
          (response) ->
            $uibModalInstance.close(response)
          (error) ->
            toastr.warning("mno_enterprise.auth.sessions.timeout.error")
            $uibModalInstance.dismiss('cancel')
            $state.go('logout')
        ).finally(-> $scope.isLoading = false)

      $scope.logOff = () ->
        $uibModalInstance.dismiss('cancel')
        $state.go('logout')

    return @
