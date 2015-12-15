#
# Loading Directive
#
angular.module 'mnoEnterpriseAngular'
  .directive('mnoLoader', ->
    restrict: 'AE'
    template: '<div class="loading"><i class="fa fa-2x fa-spin fa-refresh"></i></div>'
  )
