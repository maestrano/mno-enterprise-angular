angular.module 'mnoEnterpriseAngular'
  .factory 'MnoeConfig', ($log, AUDIT_LOG) ->
    _self = @

    @isAuditLogEnabled = () ->
      if AUDIT_LOG
        AUDIT_LOG.enabled
      else
        false

    return @
