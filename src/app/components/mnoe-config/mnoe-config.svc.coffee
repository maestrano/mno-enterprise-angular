angular.module 'mnoEnterpriseAngular'
  .factory 'MnoeConfig', ($log, DASHBOARD_CONFIG, ADMIN_PANEL_CONFIG) ->
    _self = @

    @isImpacEnabled = () ->
      if DASHBOARD_CONFIG.impac?.enabled?
        DASHBOARD_CONFIG.impac.enabled
      else
        $log.debug("DASHBOARD_CONFIG.impac.enabled missing")
        true

    @isAuditLogEnabled = () ->
      if DASHBOARD_CONFIG.audit_log?.enabled?
        DASHBOARD_CONFIG.audit_log.enabled
      else
        $log.debug("DASHBOARD_CONFIG.audit_log.enabled missing")
        false

    @isBillingEnabled = () ->
      if DASHBOARD_CONFIG.organization_management?.billing?.enabled?
        DASHBOARD_CONFIG.organization_management.billing.enabled
      else
        $log.debug("DASHBOARD_CONFIG.organization_management.billing.enabled missing")
        true

    @isDeveloperSectionEnabled = () ->
      if DASHBOARD_CONFIG.developer?.enabled?
        DASHBOARD_CONFIG.developer.enabled
      else
        $log.debug("DASHBOARD_CONFIG.developer.enabled missing")
        false

    @isDockEnabled = () ->
      if DASHBOARD_CONFIG.dock?.enabled?
        DASHBOARD_CONFIG.dock.enabled
      else
        $log.debug("DASHBOARD_CONFIG.dock.enabled missing")
        true

    @marketplaceCurrency = () ->
      if DASHBOARD_CONFIG.marketplace?.pricing?.currency?
        DASHBOARD_CONFIG.marketplace.pricing.currency
      else
        $log.debug("DASHBOARD_CONFIG.marketplace.pricing.currency missing")
        'AUD'

    @isMarketplaceEnabled = () ->
      if DASHBOARD_CONFIG.marketplace?.enabled?
        DASHBOARD_CONFIG.marketplace.enabled
      else
        $log.debug("DASHBOARD_CONFIG.marketplace.enabled missing")
        false

    @isProvisioningEnabled = () ->
      if DASHBOARD_CONFIG.marketplace?.provisioning?
        DASHBOARD_CONFIG.marketplace.provisioning
      else
        $log.debug("DASHBOARD_CONFIG.marketplace.provisioning")
        false

    @areLocalProductsEnabled = () ->
      if DASHBOARD_CONFIG.marketplace?.local_products?
        DASHBOARD_CONFIG.marketplace.local_products
      else
        $log.debug("DASHBOARD_CONFIG.marketplace.local_products")
        false

    @publicLocalProducts = () ->
      if DASHBOARD_CONFIG.public_pages?.local_products?
        DASHBOARD_CONFIG.public_pages.local_products
      else
        $log.debug("DASHBOARD_CONFIG.public_pages.local_products missing")
        []

    @publicHighlightedLocalProducts = () ->
      if DASHBOARD_CONFIG.public_pages?.highlighted_local_products?
        DASHBOARD_CONFIG.public_pages.highlighted_local_products
      else
        $log.debug("DASHBOARD_CONFIG.public_pages.highlighted_local_products missing")
        []

    @isMarketplaceComparisonEnabled = () ->
      if DASHBOARD_CONFIG.marketplace?.comparison?.enabled?
        DASHBOARD_CONFIG.marketplace.comparison.enabled
      else
        $log.debug("DASHBOARD_CONFIG.marketplace.comparison.enabled missing")
        false

    @isMarketplacePricingEnabled = () ->
      if DASHBOARD_CONFIG.marketplace?.pricing?.enabled?
        DASHBOARD_CONFIG.marketplace.pricing.enabled
      else
        $log.debug("DASHBOARD_CONFIG.marketplace.pricing.enabled missing")
        true

    @areMarketplaceReviewsEnabled = () ->
      if DASHBOARD_CONFIG.marketplace?.reviews?.enabled?
        DASHBOARD_CONFIG.marketplace.reviews.enabled
      else
        $log.debug("DASHBOARD_CONFIG.marketplace.reviews.enabled missing")
        true

    @areMarketplaceQuestionsEnabled = () ->
      if DASHBOARD_CONFIG.marketplace?.questions?.enabled?
        DASHBOARD_CONFIG.marketplace.questions.enabled
      else
        $log.debug("DASHBOARD_CONFIG.marketplace.questions.enabled missing")
        true

    @isOnboardingWizardEnabled = () ->
      # commented until products are properly handled
      # if DASHBOARD_CONFIG.onboarding_wizard?.enabled?
      #   DASHBOARD_CONFIG.onboarding_wizard.enabled
      # else
      #   $log.debug("DASHBOARD_CONFIG.onboarding_wizard.enabled missing")
      #   false
      false

    @isOrganizationManagementEnabled = () ->
      if DASHBOARD_CONFIG.organization_management?.enabled?
        DASHBOARD_CONFIG.organization_management.enabled
      else
        $log.debug("DASHBOARD_CONFIG.organization_management.enabled missing")
        true

    @isPaymentEnabled = () ->
      if DASHBOARD_CONFIG.payment?.enabled?
        DASHBOARD_CONFIG.payment.enabled
      else
        $log.debug("DASHBOARD_CONFIG.payment.enabled missing")
        true

    @arePublicApplicationsEnabled = () ->
      if DASHBOARD_CONFIG.public_pages?.enabled?
        DASHBOARD_CONFIG.public_pages.enabled
      else
        $log.debug("DASHBOARD_CONFIG.public_pages.enabled missing")
        false

    @isPublicPricingEnabled = () ->
      if DASHBOARD_CONFIG.public_pages?.display_pricing?
        DASHBOARD_CONFIG.public_pages.display_pricing
      else
        $log.debug("DASHBOARD_CONFIG.public_pricing.display_pricing missing")

    @publicProducts = () ->
      if DASHBOARD_CONFIG.public_pages?.products?
        DASHBOARD_CONFIG.public_pages.products
      else
        $log.debug("DASHBOARD_CONFIG.public_pages.applications missing")
        []

    @publicHighlightedApplications = () ->
      if DASHBOARD_CONFIG.public_pages?.highlighted_applications?
        DASHBOARD_CONFIG.public_pages.highlighted_applications
      else
        $log.debug("DASHBOARD_CONFIG.public_pages.highlighted_applications missing")
        []

    @isRegistrationEnabled = () ->
      if DASHBOARD_CONFIG.registration?.enabled?
        DASHBOARD_CONFIG.registration.enabled
      else
        true

    @isUserManagementEnabled = () ->
      if DASHBOARD_CONFIG.user_management?.enabled?
        DASHBOARD_CONFIG.user_management.enabled
      else
        $log.debug("DASHBOARD_CONFIG.user_management.enabled missing")
        true

    @isImpersonationConsentRequired = () ->
      if ADMIN_PANEL_CONFIG.impersonation?.consent_required?
        ADMIN_PANEL_CONFIG.impersonation.consent_required
      else
        false

    @availableBillingCurrencies = () ->
      if DASHBOARD_CONFIG.available_billing_currencies?
        DASHBOARD_CONFIG.available_billing_currencies
      else
        $log.debug("DASHBOARD_CONFIG.billing_currencies missing")
        ['AED', 'AUD', 'CAD', 'EUR', 'GBP', 'HKD', 'JPY', 'NZD', 'SGD', 'USD']

    return @
