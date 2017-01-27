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
    # as the /marketplace payload isn't encapsulated in "{ marketplace: categories {...}, apps {...} }"
    marketplaceApi = MnoeApiSvc.oneUrl('/marketplace')
    marketplacePromise = null

    @getApps = () ->
      return marketplacePromise if marketplacePromise?
      marketplacePromise = marketplaceApi.get()

    @getReviews = (appId, limit, offset, sort) ->
      params = ({order_by: sort, limit: limit, offset: offset})
      MnoeFullApiSvc.one('marketplace', parseInt(appId)).all('app_feedbacks').getList(params)

    @getQuestions = (appId, limit, offset, search) ->
      params = ({limit: limit, offset: offset, search: search})
      MnoeFullApiSvc.one('marketplace', parseInt(appId)).all('app_questions').getList(params)

    @addAppReview = (appId, data) ->
      payload = {app_review: data}
      MnoeFullApiSvc.one('marketplace', parseInt(appId)).post('/app_reviews', payload).then(
        (response) ->
          app_review = response.data.plain()
          app_review
      )

    @addAppQuestion = (appId, data) ->
      payload = {app_question: data}
      MnoeFullApiSvc.one('marketplace', parseInt(appId)).post('/app_questions', payload).then(
        (response) ->
          app_question = response.data.plain()
          app_question
      )

    @editReview = (appId, feedback_id, feedback) ->
      payload = feedback
      MnoeFullApiSvc.one("marketplace/#{parseInt(appId)}/app_feedbacks/#{feedback_id}").patch(payload).then(
        (response) ->
          app_review = response.data.plain()
          app_review
      )

    @addAppReviewComment = (appId, data) ->
      payload = {app_comment: data}
      MnoeFullApiSvc.one('marketplace', parseInt(appId)).post('/app_comments', payload).then(
        (response) ->
          app_comment = response.data.plain()
          app_comment
      )

    @addAppQuestionAnswer = (appId, data) ->
      payload = {app_answer: data}
      MnoeFullApiSvc.one('marketplace', parseInt(appId)).post('/app_answers', payload).then(
        (response) ->
          app_answer = response.data.plain()
          app_answer
      )

    return @
