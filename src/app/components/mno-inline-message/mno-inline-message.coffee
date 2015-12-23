angular.module 'mnoEnterpriseAngular'
  .directive('mnoInlineMessage', () ->
    return {
      restrict: 'AE',
      scope: {
        on: '=',
        message: '@'
      },
      templateUrl: 'app/components/mno-inline-message/mno-inline-message.html'
    }
  )
