# Service for the listing of Apps on the Markeplace
# MnoeMarketplace.getList()

# .getApps()
# => GET /mnoe/jpi/v1/marketplace
# Return the list off apps and categories
#   {categories: [], apps: []}

# .getApp(1)
# => GET /mnoe/jpi/v1/marketplace/1
# Return an app
angular.module 'mnoEnterpriseAngular'
  .service 'MnoeMarketplace', ($log, MnoeApiSvc) ->
    _self = @

    # Using this syntax will not trigger the data extraction in MnoeApiSvc
    # as the /marketplace payload isn't encapsulated in "{ marketpalce: categories {}, apps {...} }"
    marketplaceApi = MnoeApiSvc.oneUrl('/marketplace')

    @getApps = () ->
      marketplaceApi.get()

    @getApp = (id) ->
      marketplaceApi.one(id).get().then(
        (response) ->
          $log.debug(data)
          # TODO
          response
      )

    return @

