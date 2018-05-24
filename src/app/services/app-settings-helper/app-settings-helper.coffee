angular.module 'mnoEnterpriseAngular'
  .service 'AppSettingsHelper', ($window) ->
    _self = @

    @isAddOnSettingShown = (app) ->
      app.add_on

    @addOnSettingLauch = (app) ->
      $window.open("/mnoe/launch/#{app.uid}?settings=true", '_blank')
      return true

    return @
