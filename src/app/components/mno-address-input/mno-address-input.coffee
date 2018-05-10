angular.module 'mnoEnterpriseAngular'
  .directive('mnoAddressInput', ->
    return {
      restrict: 'EA'
      templateUrl: 'app/components/mno-address-input/mno-address-input.html',
      scope: {
        address: '='
      }

      controller: ($scope, Miscellaneous) ->
        $scope.validCountries = Miscellaneous.countries
        return
    }
)
