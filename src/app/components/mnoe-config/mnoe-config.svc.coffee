angular.module 'mnoEnterpriseAngular'
  .factory 'MnoeConfig', ($log, AUDIT_LOG, ORGANIZATION_MANAGEMENT) ->
    _self = @

    @isAuditLogEnabled = () ->
      if AUDIT_LOG
        AUDIT_LOG.enabled
      else
        false

    @isBillingEnabled = () ->
      if ORGANIZATION_MANAGEMENT? && ORGANIZATION_MANAGEMENT.billing?
        ORGANIZATION_MANAGEMENT.billing.enabled
      else
        true

    return @
