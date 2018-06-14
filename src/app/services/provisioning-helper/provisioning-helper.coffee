angular.module 'mnoEnterpriseAngular'
  .service 'ProvisioningHelper', (PRICING_TYPES) ->
    _self = @

    @pricedPlan = (plan) ->
      plan.pricing_type not in PRICING_TYPES['unpriced']

    @plansForCurrency = (plans, currency) ->
      if _.isArray(plans)
        _.filter(plans,
          (pp) -> !_self.pricedPlan(pp) || _.some(pp.prices, (p) -> p.currency == currency)
        )
      else
        plansWithoutDefault = _.clone(plans, true)
        delete plansWithoutDefault.default

        pricingPlans = _.flatten(_.values(plansWithoutDefault))
        _.filter(pricingPlans,
          (pp) -> !_self.pricedPlan(pp) || pp.currency == currency
        )

    # Skip pricing selection for products with product_type 'application',
    # where singly billing is disabled and the product is externally provisioned.
    @skipPriceSelection = (product) ->
      product?.product_type == 'application' && !product?.single_billing_enabled && !product?.externally_provisioned

    return @
