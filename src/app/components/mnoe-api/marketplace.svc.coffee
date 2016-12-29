# Service for the listing of Apps on the Markeplace
# MnoeMarketplace.getList()

# .getApps()
# => GET /mnoe/jpi/v1/marketplace
# Return the list off apps and categories
#   {categories: [], apps: []}
angular.module 'mnoEnterpriseAngular'
  .service 'MnoeMarketplace', ($log, MnoeApiSvc, MnoeFullApiSvc) ->
    _self = @

    # Using this syntax will not trigger the data extraction in MnoeApiSvc
    # as the /marketplace payload isn't encapsulated in "{ marketpalce: categories {...}, apps {...} }"
    marketplaceApi = MnoeApiSvc.oneUrl('/marketplace')
    marketplacePromise = null

    @getApps = () ->
      return marketplacePromise if marketplacePromise?
      marketplacePromise = marketplaceApi.get()

    @getReviews = (appId, limit, offset, sort) ->
      params = ({order_by: sort, limit: limit, offset: offset})
      MnoeFullApiSvc.one('marketplace', parseInt(appId)).all('app_reviews').getList(params)

    @addAppReview = (appId, data) ->
      payload = {app_review: data}
      MnoeFullApiSvc.one('marketplace', parseInt(appId)).post('app_reviews', payload).then(
        (response) ->
          app_review = response.data.plain()
          app_review
      )

    return @
