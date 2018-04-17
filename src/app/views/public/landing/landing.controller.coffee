angular.module 'mnoEnterpriseAngular'
  .controller('LandingCtrl',
    ($scope, $rootScope, $state, $stateParams, $window, MnoeConfig, MnoeMarketplace, URI) ->

      vm = @
      vm.isLoading = true
      vm.localProductLoading = true
      vm.highlightedApps = []
      vm.localProducts = []

      vm.carouselImageStyle = (app) ->
        # Products does not have a picture
        picture = if app.pictures then app.pictures[0] else app.logo
        {
          "background-image": "url(#{picture})"
        }

      MnoeMarketplace.getApps().then(
        (response) ->
          vm.products = _.filter(response.apps, (app) -> _.includes(MnoeConfig.publicApplications(), app.nid))
          vm.highlightedApps = _.filter(response.apps, (app) -> _.includes(MnoeConfig.publicHighlightedApplications(), app.nid))
          if MnoeConfig.areLocalProductsEnabled
            vm.localProducts = _.filter(response.products, (product) -> product.local && _.includes(MnoeConfig.publicLocalProducts(), product.nid))
            localHighlightedApp = _.filter(response.products, (product) -> _.includes(MnoeConfig.publicHighlightedLocalProducts(), product.nid))
            vm.highlightedApps = vm.highlightedApps.concat(localHighlightedApp) if localHighlightedApp
          vm.categories = response.categories
      ).finally(-> vm.isLoading = false)

      vm.highlightHref = (app) ->
        if app.local
          "public.local_product({productId: app.nid})"
        else
          "public.product({appId: app.nid})"

      return
  )
