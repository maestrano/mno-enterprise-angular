# Service for managing the users.
angular.module 'mnoEnterpriseAngular'
  .service 'MnoeProvisioning', ($q, $log, MnoeApiSvc) ->
    _self = @

    provisioningApi = MnoeApiSvc.oneUrl('/provisioning')
    provisioningPromise = null
    provisioningResponse = null

    productsApi = MnoeApiSvc.oneUrl('/products')
    productsResponse = null

    pricingPlan = null
    customData = null

    @getProducts = () ->
      productsApi.get().then(
        (response) ->
          console.log("### DEBUG products", response.plain())
          productsResponse = response.plain()
          response
      )

    @findProduct = (nid) ->
      _.find(productsResponse.products, (a) -> a.nid == nid)

    @setPricingPlan = (p) ->
      pricingPlan = p

    @setCustomData = (data) ->
      customData = data

    @fetchJsonSchema = () ->
      $q.resolve({
        "$schema": "http://json-schema.org/draft-04/hyper-schema",
        "id": "microsoft"
        "title": "Microsoft Office 365 Provisioning",
        "type": "object",
        "properties": {
          "customer": {
            "id": "customer",
            "type": "object",
            "title": "Customer",
            "properties": {
              "domain": {
                "id": "domain",
                "title": "Microsoft Customer Domain",
                "readOnly": false,
                "pattern": "^(w+)$",
                "strictProperties": true,
                "type": "string",
                "propertyOrder": 1,
                "options": {
                  "hidden": false
                }
              },
              "country": {
                "id": "country",
                "title": "Microsoft Customer Country 2 letters code",
                "readOnly": false,
                "pattern": "^([A-Z]{2})$",
                "strictProperties": true,
                "type": "string",
                "propertyOrder": 2,
                "options": {
                  "hidden": false
                }
              },
              "address": {
                "id": "address",
                "type": "object",
                "title": "Address",
                "properties": {
                  "address_line_1": {
                    "id": "address_line_1",
                    "title": "Address Line 1",
                    "readOnly": false,
                    "strictProperties": true,
                    "type": "string",
                    "propertyOrder": 3,
                    "options": {
                      "hidden": false
                    }
                  },
                  "address_line_2": {
                    "id": "address_line_2",
                    "title": "Address Line 2",
                    "readOnly": false,
                    "strictProperties": false,
                    "type": "string",
                    "propertyOrder": 4,
                    "options": {
                      "hidden": false
                    }
                  },
                  "city": {
                    "id": "city",
                    "title": "City",
                    "readOnly": false,
                    "strictProperties": true,
                    "type": "string",
                    "propertyOrder": 5,
                    "options": {
                      "hidden": false
                    }
                  },
                  "state": {
                    "id": "state",
                    "title": "State",
                    "readOnly": false,
                    "strictProperties": false,
                    "type": "string",
                    "propertyOrder": 6,
                    "options": {
                      "hidden": false
                    }
                  },
                  "postal_code": {
                    "id": "postal_code",
                    "title": "Postal Code",
                    "readOnly": false,
                    "strictProperties": true,
                    "type": "string",
                    "propertyOrder": 7,
                    "options": {
                      "hidden": false
                    }
                  }
                }
              },
              "phone_number": {
                "id": "phone_number",
                "title": "Phone Number",
                "readOnly": false,
                "strictProperties": true,
                "type": "string",
                "propertyOrder": 8,
                "options": {
                  "hidden": false
                }
              },
              "first_name": {
                "id": "first_name",
                "title": "First Name",
                "readOnly": false,
                "strictProperties": true,
                "type": "string",
                "propertyOrder": 9,
                "options": {
                  "hidden": false
                }
              },
              "last_name": {
                "id": "last_name",
                "title": "Last Name",
                "readOnly": false,
                "strictProperties": true,
                "type": "string",
                "propertyOrder": 10,
                "options": {
                  "hidden": false
                }
              },
              "email_address": {
                "id": "email_address",
                "title": "Email",
                "readOnly": false,
                "strictProperties": true,
                "type": "string",
                "propertyOrder": 11,
                "options": {
                  "hidden": false
                }
              }
            }
          }
        }
      })

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
