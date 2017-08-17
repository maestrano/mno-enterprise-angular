angular.module 'mnoEnterpriseAngular'
  .service 'MnoeProductInstances', (MnoeApiSvc, MnoeOrganizations) ->
    _self = @

    @getProductInstances = ->
      MnoeApiSvc.one('organizations', MnoeOrganizations.selectedId).one('/product_instances').get().then(
        (response) ->
          response = response.plain()
      )

    @addProductInstance = (product_id) ->
      payload = { product_id: product_id }
      MnoeApiSvc.one('organizations', MnoeOrganizations.selectedId).post('product_instances', payload).then(
        (response) ->
          response = response.plain()
          response = response.product_instances
      )

    return @
