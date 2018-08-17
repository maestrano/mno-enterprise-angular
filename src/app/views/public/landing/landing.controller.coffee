angular.module 'mnoEnterpriseAngular'
  .controller('LandingCtrl',
    ($scope, $rootScope, $state, $stateParams, $window, MnoeConfig, MnoeMarketplace, URI) ->

      vm = @
      vm.isLoading = true
      vm.highlightedApps = []
      vm.localProducts = []

      vm.carouselImageStyle = (app) ->
        # Select appropriate image for carousel - logo or picture
        picture = if app.pictures then app.pictures[0] else app.logo
        {
          "background-image": "url(#{picture})"
        }

      MnoeMarketplace.getApps().then(
        (response) ->
          vm.highlightedApps = _.filter(response.apps, (app) -> _.includes(MnoeConfig.publicHighlightedApplications(), app.nid))
          if MnoeConfig.areLocalProductsEnabled
            vm.localProducts = _.filter(response.products, (product) -> product.local && _.includes(MnoeConfig.publicLocalProducts(), product.nid))
            localHighlightedApp = _.filter(response.products, (product) -> _.includes(MnoeConfig.publicHighlightedLocalProducts(), product.nid))
            vm.highlightedApps = vm.highlightedApps.concat(localHighlightedApp) if localHighlightedApp
      ).finally(-> vm.isLoading = false)

      vm.highlightHref = (app) ->
        if app.local
          "public.local_product({productId: app.nid})"
        else
          "public.product({appId: app.nid})"

      return
  )
