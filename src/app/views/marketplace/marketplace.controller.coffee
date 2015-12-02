angular.module 'mnoEnterpriseAngular'
  .controller('DashboardMarketplaceCtrl', ($scope, MarketplaceSvc) ->

    #====================================
    # Pre-Initialization
    #====================================
    $scope.isLoading = true
    $scope.selectedCategory = ''
    $scope.searchTerm = ''
    $scope.appFilter = ''

    #====================================
    # Scope Management
    #====================================
    $scope.initialize = (marketplace)->
      $scope.categories = marketplace.categories
      $scope.apps = marketplace.apps
      $scope.isLoading = false

    $scope.linkFor = (app) ->
      "#/marketplace/#{app.id}"

    $scope.appsFilter = (app) ->
      if ($scope.searchTerm? && $scope.searchTerm.length > 0) || !$scope.selectedCategory
        return true
      else
        return _.contains(app.categories,$scope.selectedCategory)

    #====================================
    # Post-Initialization
    #====================================
    MarketplaceSvc.load().then (marketplace)->
      $scope.initialize(marketplace)
)
