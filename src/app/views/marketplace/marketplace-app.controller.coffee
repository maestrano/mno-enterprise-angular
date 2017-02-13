#============================================
#
#============================================
angular.module 'mnoEnterpriseAngular'
  .controller('DashboardMarketplaceAppCtrl',($q, $scope, $stateParams, $state, $sce, $window, $uibModal, toastr,
    MnoeMarketplace, MnoeOrganizations, MnoeCurrentUser, MnoeAppInstances, MnoConfirm, MnoErrorsHandler,
    PRICING_CONFIG, REVIEWS_CONFIG) ->

      vm = this

      #====================================
      # Pre-Initialization
      #====================================
      vm.isLoading = true
      vm.app = {}
      # The already installed app instance of the app, if any
      vm.appInstance = null
      # An already installed app, conflicting with the app because it contains a common subcategory
      # that is not multi instantiable, if any
      vm.conflictingApp = null
      # Enabling pricing
      vm.isPriceShown = PRICING_CONFIG && PRICING_CONFIG.enabled
      # Enabling reviews
      vm.isReviewingEnabled = REVIEWS_CONFIG && REVIEWS_CONFIG.enabled

      vm.averageRating = 5

      vm.sortReviewsBy = 'created_at.desc'

      #====================================
      # Scope Management
      #====================================
      vm.initialize = (app, appInstance, conflictingApp) ->
        # Variables initialization

        vm.userId = MnoeCurrentUser.user.id
        vm.adminRole = MnoeCurrentUser.user.admin_role

        vm.reviews =
          loading: true
          nbItems: 5
          page: 1
          pageChangedCb: (appId, nbItems, page) ->
            vm.reviews.nbItems = nbItems
            vm.reviews.page = page
            offset = (page  - 1) * nbItems
            fetchReviews(appId, nbItems, offset, vm.sortReviewsBy)

        vm.questions =
          laoding: true
          nbItems: 100
          page: 1
          searchWord: ''
          pageChangedCb: (appId, nbItems, page) ->
            vm.questions.nbItems = nbItems
            vm.questions.page = page
            offset = (page  - 1) * nbItems
            fetchQuestions(appId, nbItems, offset, searchWord)

        angular.copy(app, vm.app)

        # Fetch initials reviews
        if vm.isReviewingEnabled
          fetchReviews(app.id, vm.reviews.nbItems, 0)
          fetchQuestions(app.id, vm.questions.nbItems, 0)
          vm.averageRating = parseFloat(vm.app.average_rating).toFixed(1)
          vm.isRateDisplayed = !!vm.averageRating

        vm.appInstance = appInstance
        vm.conflictingApp = conflictingApp
        vm.app.description = $sce.trustAsHtml(app.description)
        plans = vm.app.pricing_plans
        currency = (PRICING_CONFIG && PRICING_CONFIG.currency) || 'AUD'
        vm.pricing_plans = plans[currency] || plans.AUD || plans.default

        # Get the user role in this organization
        MnoeOrganizations.get().then((response) -> vm.user_role = response.current_user.role)

        vm.isLoading = false

        # Check that the testimonial is not empty
        vm.isTestimonialShown = (testimonial) ->
          testimonial.text? && testimonial.text.length > 0

        vm.canUserEditReview = (review) ->
          (review.user_id == vm.userId) && (review.edited_by_id == review.user_id || !review.edited_by_id)
        #====================================
        # Cart Management
        #====================================
        vm.cart = cart = {
          isOpen: false
          bundle: {}
          config: {}
        }

        # Open the ShoppingCart
        cart.open = ->
          cart.config.organizationId = MnoeOrganizations.selectedId
          cart.bundle = { app_instances: [{app: { id: vm.app.id }}] }
          cart.isOpen = true

      #====================================
      # Reviews
      #====================================
      vm.openCreateReviewModal = ->
        modalInstance = $uibModal.open(
          templateUrl: 'app/views/marketplace/modals/create-review-modal.html'
          controller: 'CreateReviewModalCtrl'
          controllerAs: 'vm',
          size: 'lg'
          windowClass: 'inverse'
          backdrop: 'static'
        )
        modalInstance.result.then(
          (response) ->
            # Increment # of items
            vm.reviews.totalItems++
            # Add new element at the beginning
            vm.reviews.list.unshift(response.app_review)
            # Remove last element if needed
            vm.reviews.list.pop() if vm.reviews.list.length > vm.reviews.nbItems
            # Update average rating
            vm.averageRating = Math.round(parseFloat(vm.app.average_rating).toFixed(1))
        )

      #====================================
      # Edit review
      #====================================
      vm.openEditReviewModal = (review, key)->
        modalInstance = $uibModal.open(
          templateUrl: 'app/views/marketplace/modals/edit-review-modal.html'
          controller: 'EditReviewModalCtrl'
          controllerAs: 'vm',
          size: 'lg'
          windowClass: 'inverse'
          backdrop: 'static'
          resolve:
            review: review
        )
        modalInstance.result.then(
          (response) ->
            review = vm.reviews.list[key]
            review.description = response.app_feedback.description
            review.rating = response.app_feedback.rating
            review.edited = response.app_feedback.edited
            review.edited_by_id = response.app_feedback.edited_by_id
            vm.averageRating = Math.round(parseFloat(vm.app.average_rating).toFixed(1))
        )

      #====================================
      # Delete review
      #====================================
      vm.openDeleteReviewModal = (review, key)->
        modalOptions =
          headerText: "mno_enterprise.templates.dashboard.marketplace.show.review.delete_modal_header"
          bodyText: "mno_enterprise.templates.dashboard.marketplace.show.review.delete_modal_body"
          closeButtonText: 'mno_enterprise.templates.dashboard.marketplace.show.review.delete_modal_cancel'
          actionButtonText: 'mno_enterprise.templates.dashboard.marketplace.show.review.delete_modal_delete'
          actionCb: -> MnoeMarketplace.deleteReview($stateParams.appId, review.id)
          type: 'danger'

        MnoConfirm.showModal(modalOptions).then(
          (response) ->
            vm.reviews.list.splice(key, 1)
            vm.averageRating = parseFloat(response.average_rating).toFixed(1)
        )

      #====================================
      # Comments
      #====================================
      vm.openCreateCommentModal = (feedback, key) ->
        modalInstance = $uibModal.open(
          templateUrl: 'app/views/marketplace/modals/create-comment-modal.html'
          controller: 'CreateCommentModalCtrl'
          controllerAs: 'vm',
          size: 'lg'
          windowClass: 'inverse'
          backdrop: 'static'
          resolve:
            feedback: feedback
        )
        modalInstance.result.then(
          (response) ->
            vm.reviews.list[key].comments.push(response.app_comment)
        )

      #====================================
      # Edit comment
      #====================================
      vm.openEditCommentModal = (comment, key, reviewKey)->
        modalInstance = $uibModal.open(
          templateUrl: 'app/views/marketplace/modals/edit-modal.html'
          controller: 'EditCommentModalCtrl'
          controllerAs: 'vm',
          size: 'lg'
          windowClass: 'inverse'
          backdrop: 'static'
          resolve:
            object: comment
        )
        modalInstance.result.then(
          (response) ->
            comment = vm.reviews.list[key].comments[reviewKey]
            comment.description = response.app_comment.description
            comment.edited = response.app_comment.edited
            comment.edited_by_id = response.app_comment.edited_by_id
        )

      #====================================
      # Delete comment
      #====================================
      vm.openDeleteCommentModal = (comment, key, reviewKey)->
        modalOptions =
          headerText: "mno_enterprise.templates.dashboard.marketplace.show.comment.delete_modal_header"
          bodyText: "mno_enterprise.templates.dashboard.marketplace.show.comment.delete_modal_body"
          closeButtonText: 'mno_enterprise.templates.dashboard.marketplace.show.comment.delete_modal_cancel'
          actionButtonText: 'mno_enterprise.templates.dashboard.marketplace.show.comment.delete_modal_delete'
          actionCb: -> MnoeMarketplace.deleteComment($stateParams.appId, comment.id)
          type: 'danger'

        MnoConfirm.showModal(modalOptions).then(
          ->
            vm.reviews.list[reviewKey].comments.splice(key, 1)
        )

      #====================================
      # Ask question
      #====================================
      vm.openCreateQuestionModal = ->
        modalInstance = $uibModal.open(
          templateUrl: 'app/views/marketplace/modals/create-question-modal.html'
          controller: 'CreateQuestionModalCtrl'
          controllerAs: 'vm',
          size: 'lg'
          windowClass: 'inverse'
          backdrop: 'static'
        )
        modalInstance.result.then(
          (response) ->
            vm.questions.list.unshift(response.app_question)
        )

      #====================================
      # Edit question
      #====================================
      vm.openEditQuestionModal = (question, key)->
        modalInstance = $uibModal.open(
          templateUrl: 'app/views/marketplace/modals/edit-modal.html'
          controller: 'EditQuestionModalCtrl'
          controllerAs: 'vm',
          size: 'lg'
          windowClass: 'inverse'
          backdrop: 'static'
          resolve:
            question: question
        )
        modalInstance.result.then(
          (response) ->
            vm.questions.list[key].description = response.app_question.description
        )

      #====================================
      # Delete question
      #====================================
      vm.openDeleteQuestionModal = (question, key)->
        modalOptions =
          headerText: "mno_enterprise.templates.dashboard.marketplace.show.question.delete_modal_header"
          bodyText: "mno_enterprise.templates.dashboard.marketplace.show.question.delete_modal_body"
          closeButtonText: 'mno_enterprise.templates.dashboard.marketplace.show.question.delete_modal_cancel'
          actionButtonText: 'mno_enterprise.templates.dashboard.marketplace.show.question.delete_modal_delete'
          actionCb: -> MnoeMarketplace.deleteQuestion($stateParams.appId, question.id)
          type: 'danger'

        MnoConfirm.showModal(modalOptions).then(
          ->
            vm.questions.list.splice(key, 1)
        )

      #====================================
      # Answer
      #====================================
      vm.openCreateAnswerModal = (question, key) ->
        modalInstance = $uibModal.open(
          templateUrl: 'app/views/marketplace/modals/create-answer-modal.html'
          controller: 'CreateAnswerModalCtrl'
          controllerAs: 'vm',
          size: 'lg'
          windowClass: 'inverse'
          backdrop: 'static'
          resolve:
            question: question
        )
        modalInstance.result.then(
          (response) ->
            vm.questions.list[key].answers.push(response.app_answer)
        )

      #====================================
      # Edit answer
      #====================================
      vm.openEditAnswerModal = (answer, key, questionKey)->
        modalInstance = $uibModal.open(
          templateUrl: 'app/views/marketplace/modals/edit-modal.html'
          controller: 'EditAnswerModalCtrl'
          controllerAs: 'vm',
          size: 'lg'
          windowClass: 'inverse'
          backdrop: 'static'
          resolve:
            object: answer
        )
        modalInstance.result.then(
          (response) ->
            vm.questions.list[questionKey].answers[key].description = response.app_answer.description
        )

      #====================================
      # Delete answer
      #====================================
      vm.openDeleteAnswerModal = (answer, key, questionKey)->
        modalOptions =
          headerText: "mno_enterprise.templates.dashboard.marketplace.show.answer.delete_modal_header"
          bodyText: "mno_enterprise.templates.dashboard.marketplace.show.answer.delete_modal_body"
          closeButtonText: 'mno_enterprise.templates.dashboard.marketplace.show.answer.delete_modal_cancel'
          actionButtonText: 'mno_enterprise.templates.dashboard.marketplace.show.answer.delete_modal_delete'
          actionCb: -> MnoeMarketplace.deleteAnswer($stateParams.appId, answer.id)
          type: 'danger'

        MnoConfirm.showModal(modalOptions).then(
          ->
            vm.questions.list[questionKey].answers.splice(key, 1)
        )

      vm.showHistory = (review) ->
        $uibModal.open(
          templateUrl:  'app/views/marketplace/modals/review-history-modal.html'
          controller: 'ReviewHistoryModalCtrl'
          controllerAs: 'vm',
          size: 'lg'
          windowClass: 'inverse'
          backdrop: 'static'
          resolve:
            review: review
        )

      vm.searchQuestion = () ->
        fetchQuestions(vm.app.id, vm.questions.nbItems, vm.questions.offset, vm.questions.searchWord)

      vm.orderFeedbacks = () ->
        fetchReviews(vm.app.id, vm.reviews.nbItems, 0, vm.sortReviewsBy)

      fetchReviews = (appId, limit, offset, sort = 'created_at.desc') ->
        vm.reviews.loading = true
        MnoeMarketplace.getReviews(appId, limit, offset, sort).then(
          (response) ->
            vm.reviews.totalItems = response.headers('x-total-count')
            vm.reviews.list = response.data
        ).finally(-> vm.reviews.loading = false)

      fetchQuestions = (appId, limit, offset, search = '') ->
        vm.questions.loading = true
        MnoeMarketplace.getQuestions(appId, limit, offset, search).then(
          (response) ->
            vm.questions.list = response.data
        ).finally(-> vm.questions.loading = false)

      #====================================
      # Post-Initialization
      #====================================

      $scope.$watch MnoeOrganizations.getSelectedId, (val) ->
        if val?
          vm.isLoading = true
          # Retrieve the apps and the app instances in order to retrieve the current app, and its conflicting status
          # with the current installed app instances
          $q.all(
            marketplace: MnoeMarketplace.getApps(),
            appInstances: MnoeAppInstances.getAppInstances()
          ).then(
            (response)->
              apps = response.marketplace.apps
              appInstances = response.appInstances

              # App to be added
              appId = parseInt($stateParams.appId)
              app = _.findWhere(apps, { nid: $stateParams.appId })
              app ||= _.findWhere(apps, { id:  appId})

              # Find if we already have it
              appInstance = _.find(appInstances, { app_nid: app.nid})

              # Get the list of installed Apps
              nids = _.compact(_.map(appInstances, (a) -> a.app_nid))
              installedApps = _.filter(apps, (a) -> a.nid in nids)

              # Find conflicting app with the current app based on the subcategories
              # If there is already an installed app, with a common subcategory with the app that is not multi_instantiable
              # We keep that app, as a conflictingApp, to explain why the app cannot be installed.
              if app.subcategories
                # retrieve the subcategories names
                names = _.map(app.subcategories, 'name')

                conflictingApp = _.find(installedApps, (app) ->
                  _.find(app.subcategories, (subCategory) ->
                    not subCategory.multi_instantiable and subCategory.name in names
                  )
                )

              vm.initialize(app, appInstance, conflictingApp)
          )

      return
  )
