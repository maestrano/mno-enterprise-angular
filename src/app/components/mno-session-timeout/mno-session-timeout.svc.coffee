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
        keyboard: false
        backdrop: 'static'
        templateUrl: 'app/components/mno-session-timeout/mno-session-timeout.html'
        controller: modalController)


    modalController = ($scope, $state, $uibModalInstance, MnoeCurrentUser, toastr) ->
      'ngInject'

      $scope.stayLoggedIn = () ->
        $scope.isLoading = true
        MnoeCurrentUser.refresh().then(
          (response) ->
            toastr.success("You successsfully stayed logged in", "Success")
            $uibModalInstance.close(response)
          (error) ->
            toastr.alert("We couldnt manage to remain you logged in. You will be redirected to the login page", "Error")
            $uibModalInstance.dismiss('cancel')
            $state.go('logout')
        ).finally(-> $scope.isLoading = false)

      $scope.logOff = () ->
        $uibModalInstance.dismiss('cancel')
        $state.go('logout')

    return @
