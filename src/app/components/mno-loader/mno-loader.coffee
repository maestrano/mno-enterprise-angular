#
# Loading Directive
#
angular.module 'mnoEnterpriseAngular'
  .directive('mnoLoader', ->
    restrict: 'AE'
    template: '<div class="loading"><i class="loader-icon"></i></div>'
  )
