angular.module 'mnoEnterpriseAngular'
  .service 'MnoeInvoices', (MnoeFullApiSvc, MnoeOrganizations) ->
    _self = @

    @getInvoices = (limit, offset, sort, force = false) ->
      params = {order_by: sort, limit: limit, offset: offset}

      MnoeFullApiSvc.one('organizations', MnoeOrganizations.selectedId)
        .all('invoices')
        .getList(params)
        

    return @
