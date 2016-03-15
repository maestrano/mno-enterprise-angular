#
# Loading Directive
#
angular.module 'mnoEnterpriseAngular'
  .directive('mnoLoader', ->
    scope:
      withBackground: '='
    restrict: 'AE'
    template: '''
      <div class="loading" ng-class="{ 'with-background': withBackground }">
        <div ng-show="withBackground" class="background-layer"></div>
        <div class="fa-wrapper">
          <i class="loader-icon"></i>
        </div>
      </div>
    '''
  )
