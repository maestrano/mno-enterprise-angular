angular.module 'mnoEnterpriseAngular'
  .directive('dashboardCurrencySelection', ->
    return {
      restrict: 'EA'
      templateUrl:'app/components/dashboard-currency-select/dashboard-currency-select.html'
      controller: ($scope, $log, MnoeCurrentUser, DASHBOARD_CONFIG) ->
        isSelected = (currency) ->
          currency.selected

        # List of availables currencies
        $scope.currencies =  DASHBOARD_CONFIG.impac.currencies.replace(/ /g,'').split(",").map( (c) -> { id: c, selected: true })
        # Initialization of the selected currencies: match the user settings if possible, else all are selected (see init above)
        if MnoeCurrentUser.user.settings?.currencies?
          # Is there at least one currency in common with the user' settings?
          if $scope.currencies.some((c,i,a) -> MnoeCurrentUser.user.settings.currencies.includes(c.id) )
            # select the intersection of availbale currencies from the tenant and the settings
            $scope.currencies.map( (c) -> c.selected = MnoeCurrentUser.user.settings.currencies.includes(c.id))


        # Initialization of the default currency
        if MnoeCurrentUser.user.settings?.default_dashboard_currency?
          # Case the user has set his default, verify it is available
          $scope.defaultCurrency = $scope.currencies.find( (c) -> c.id == MnoeCurrentUser.user.settings.default_dashboard_currency  && c.selected) || $scope.currencies.find( (c) -> c.selected )
        else
          # Otherwise return the first selected currency
          $scope.defaultCurrency = $scope.currencies.find( (c) -> c.selected ) 

        $scope.changeCurrencyList = () ->
          MnoeCurrentUser.update(
            settings: Object.assign(MnoeCurrentUser.user.settings,
              currencies: $scope.currencies.filter(isSelected).map((c) -> c.id),
              default_dashboard_currency: $scope.defaultCurrency.id))
    }
  )
