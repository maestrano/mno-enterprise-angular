# Service for the listing of Apps on the Markeplace
# MnoeMarketplace.getList()

# .getApps()
# => GET /mnoe/jpi/v1/marketplace
# Return the list off apps and categories
#   {categories: [], apps: []}
angular.module 'mnoEnterpriseAngular'
  .service 'MnoeMarketplace', ($log, MnoeApiSvc, $stateParams) ->
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
      MnoeApiSvc.one('marketplace', parseInt(appId)).one('/app_reviews').get(params).then(
        (response) ->
          app_reviews = response.plain()
          app_reviews
      )

    @addAppReview = (appId, data) ->
      payload = {app_review: data}
      MnoeApiSvc.one('marketplace', parseInt(appId)).post('app_review', payload).then(
        (response) ->
          app_review = response.plain()
          app_review
      )

    return @
