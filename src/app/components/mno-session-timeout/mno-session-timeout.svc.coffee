angular.module 'mnoEnterpriseAngular'
  .service 'MnoSessionTimeout', ($rootScope, $q, $timeout, $uibModal, DEVISE_CONFIG) ->
    _self = @

    timer = null

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

      $interval((
        ->
          $scope.countdown -= 1
          if $scope.countdown == 0
            $scope.logOff(true)
        ), 1000, 10
      )

      $scope.stayLoggedIn = () ->
        $scope.isLoading = true
        $rootScope.timeoutSet = false
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
        $state.go('logout', { 'timeout': timeout })

    return @
