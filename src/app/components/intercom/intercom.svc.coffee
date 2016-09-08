angular.module 'mnoEnterpriseAngular'
  .service 'IntercomSvc', () ->
  
    @bootIntercom = (userData) ->
      window.Intercom('boot', userData )

    @updateIntercom = ->
      window.Intercom('update')

    @shutdownIntercom = ->
      Intercom('shutdown')


    return @
