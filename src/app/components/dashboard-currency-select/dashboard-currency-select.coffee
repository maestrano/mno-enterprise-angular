angular.module 'mnoEnterpriseAngular'
  .component('dashboardCurrencySelection', {
    templateUrl: 'app/components/dashboard-currency-select/dashboard-currency-select.html',
    controllerAs: "currencySelectCtrl"
    controller: (MnoeCurrentUser, DASHBOARD_CONFIG) ->
      vm = this
      isSelected = (currency) ->
        currency.selected
      # List of availables currencies
      vm.currencies = DASHBOARD_CONFIG.impac.currencies.replace(/ /g,'').split(",").map( (c) -> { id: c, selected: true })
      # Initialization of the selected currencies: match the user settings if possible, else all are selected (see init above)
      if MnoeCurrentUser.user.settings?.currencies?
        # Is there at least one currency in common with the user' settings?
        if vm.currencies.some((c,i,a) -> MnoeCurrentUser.user.settings.currencies.includes(c.id) )
          # select the intersection of available currencies from the tenant and the settings
          vm.currencies.map( (c) -> c.selected = MnoeCurrentUser.user.settings.currencies.includes(c.id))

      # Initialization of the default currency
      if MnoeCurrentUser.user.settings?.default_dashboard_currency?
        # Case the user has set his default, verify it is available
        vm.defaultCurrency = vm.currencies.find( (c) -> c.id == MnoeCurrentUser.user.settings.default_dashboard_currency  && c.selected) || vm.currencies.find( (c) -> c.selected )
      else
        # Otherwise return the first selected currency
        vm.defaultCurrency = vm.currencies.find( (c) -> c.selected ) 

      vm.changeCurrencyList = () ->
        MnoeCurrentUser.update(
          settings: Object.assign(MnoeCurrentUser.user.settings,
            currencies: vm.currencies.filter(isSelected).map((c) -> c.id),
            default_dashboard_currency: vm.defaultCurrency.id))
      return
    })
