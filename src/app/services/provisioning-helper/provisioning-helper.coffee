angular.module 'mnoEnterpriseAngular'
  .service 'ProvisioningHelper', ($state, PRICING_TYPES, MnoeProvisioning) ->
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
    # where single billing is disabled and the product is not externally provisioned.
    @skipPriceSelection = (product) ->
      product?.product_type == 'application' && !product?.single_billing_enabled && !product?.externally_provisioned

    @editSubscription = (subscription, editAction, cartSubscriptions = false) ->
      MnoeProvisioning.setSubscription({})
      if cartSubscriptions
        params = {subscriptionId: subscription.id, editAction: editAction, cart: cartSubscriptions}
      else
        params = {subscriptionId: subscription.id, editAction: editAction}

      switch editAction.toLowerCase( )
        when 'change'
          $state.go('home.provisioning.order', params)
        else
          $state.go('home.provisioning.additional_details', params)

    @showEditAction = (subscription, editAction) ->
      return false unless subscription.available_actions
      editAction in subscription.available_actions

    @goToSubscription = (subscription, cartSubscriptions = false) ->
      if cartSubscriptions
        $state.go('home.subscription', { id: subscription.id, cart: cartSubscriptions })
      else
        $state.go('home.subscription', { id: subscription.id })

    return @
