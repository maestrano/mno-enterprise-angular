angular.module 'mnoEnterpriseAngular'
  .service 'MnoeAuditEvents', ($log, MnoeFullApiSvc, MnoeOrganizations) ->
    _self = @

    _event_index = MnoeFullApiSvc.one('organizations', MnoeOrganizations.selectedId).all("audit_events")

    @list = (limit, offset, sort) ->
      params = {order_by: sort, limit: limit, offset: offset}
      _event_index.getList(params)

    @exportUrl = ->
      _event_index.getRestangularUrl() + ".csv"

    return @
