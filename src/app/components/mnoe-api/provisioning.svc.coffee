# Service for managing the users.
angular.module 'mnoEnterpriseAngular'
  .service 'MnoeProvisioning', ($log, MnoeApiSvc) ->
    _self = @

    provisioningApi = MnoeApiSvc.oneUrl('/provisioning')
    provisioningPromise = null
    provisioningResponse = null

    @getProvisioning = () ->
      # To be removed when API is ready
      return stubPromise
      return provisioningPromise if provisioningPromise?
      provisioningPromise = provisioningApi.get().then(
        (response) ->
          provisioningResponse = response
          response
      )

    @getSubscriptions = () ->
      # To be removed when API is ready
      [
        {product: 'Product 1', subscription: 'Subscription 1', description: 'Description 1', amount: '100', start_date: '2017-01-01', end_date: '2017-12-31', status: 'Fulfilled'},
        {product: 'Product 2', subscription: 'Subscription 2', description: 'Description 2', amount: '200', start_date: '2017-01-01', end_date: '2017-12-31', status: 'Fulfilled'},
        {product: 'Product 3', subscription: 'Subscription 3', description: 'Description 2', amount: '300', start_date: '2017-01-01', end_date: '2017-12-31', status: 'Fulfilled'},
        {product: 'Product 4', subscription: 'Subscription 4', description: 'Description 2', amount: '400', start_date: '2017-01-01', end_date: '2017-12-31', status: 'Fulfilled'},
      ]

    # To be removed when API is ready
    stubPromise = new Promise (resolve, reject) ->
      # do a thing
      success = true
      if success
        resolve 'stuff worked'
      else
        reject Error 'it broke'

    return
