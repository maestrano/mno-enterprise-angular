angular.module 'mnoEnterpriseAngular'
  .service 'ProvisioningHelper', (PRICING_TYPES) ->
    _self = @

    @pricedPlan = (plan) ->
      plan.pricing_type not in PRICING_TYPES['unpriced']

    @planForCurrency = (plans, currency) ->
      _.filter(plans,
        (pp) -> !_self.pricedPlan(pp) || _.some(pp.prices, (p) -> p.currency == currency)
      )

    return @
