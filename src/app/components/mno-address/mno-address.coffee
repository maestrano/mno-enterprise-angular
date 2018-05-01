angular.module 'mnoEnterpriseAngular'
  .directive('mnoAddress', ->
    return {
      restrict: 'EA'
      templateUrl: 'app/components/mno-address/mno-address.html',
      scope: {
        address: '='
      }

      controller: ($scope, Miscellaneous) ->
        $scope.validCountries = Miscellaneous.countries
        return
    }
)
