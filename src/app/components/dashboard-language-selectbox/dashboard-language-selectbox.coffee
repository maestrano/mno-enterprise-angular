
angular.module 'mnoEnterpriseAngular'
  .directive('dashboardLanguageSelectbox', ->
    return {
      restrict: 'EA'
      template: '''
        <select ng-model="selectedLangKey" ng-change="changeLanguage()">
          <option value="en">English</option>
          <option value="id">Indonesian</option>
          <option value="zh">Chinese</option>
        </select>
      '''
      controller: ($scope, $translate) ->
        'ngInject'

        $scope.changeLanguage = () ->
          $translate.use($scope.selectedLangKey)

    }
  )
