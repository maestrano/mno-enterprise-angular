angular.module 'mnoEnterpriseAngular'
  .service 'MnoSessionTimeout', ($q, $timeout, $uibModal, DEVISE_CONFIG) ->
    _self = @

    timer = null
    countdownInterval = null

    @resetTimer = ->
      _self.cancelTimer()
      timer = $timeout(showTimeoutModal, (DEVISE_CONFIG.timeout_in - 12) * 1000)

    @cancelTimer = ->
      $timeout.cancel(timer)

    showTimeoutModal = ->
      $uibModal.open({
        size: 'md'
        keyboard: false
        backdrop: 'static'
        templateUrl: 'app/components/mno-session-timeout/mno-session-timeout.html'
        controller: modalController
      })


    modalController = ($scope, $state, $interval, $uibModalInstance, MnoeCurrentUser, toastr) ->
      'ngInject'

      $scope.countdown = 10

      countdownInterval = $interval((
        ->
          $scope.countdown -= 1
          $scope.logOff(true) if $scope.countdown == 0
        ), 1000, 10
      )

      $scope.stayLoggedIn = () ->
        $scope.isLoading = true
        $interval.cancel(countdownInterval)
        MnoeCurrentUser.refresh().then(
          (response) ->
            $uibModalInstance.close(response)
          (error) ->
            toastr.warning("mno_enterprise.auth.sessions.timeout.error")
            $uibModalInstance.dismiss('cancel')
            $state.go('logout')
        ).finally(
         ->
          $scope.isLoading = false
        )

      $scope.logOff = (timeout = false) ->
        $uibModalInstance.dismiss('cancel')
        $interval.cancel(countdownInterval)
        $state.go('logout', { 'timeout': timeout })

    return @
