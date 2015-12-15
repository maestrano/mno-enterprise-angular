# Service for managing the users.
angular.module 'mnoEnterpriseAngular'
  .service 'MnoeOrganizations', ($state, $cookies, $log, MnoeApiSvc, MnoeCurrentUser) ->
    _self = @

    organizationsApi = MnoeApiSvc.all('organizations')

    @selected = null
    @selectedId = null

    @list = () ->
      organizationsApi.getList().then(
        (response) ->
          _self.list = response
          response
      )

    @inArrears = () ->
      organizationsApi.all('in_arrears').getList()

    @get = (id) ->
      _self.selectedId = id
      MnoeApiSvc.one('organizations', id).get().then(
        (response) ->
          _self.selected = response
          $cookies.put('dhb_ref_id', response.id)
          $log.debug('selected organization', response)
          response
      )

    @create = (organization) ->
      organizationsApi.post(organization)

    @update = (organization) ->
      organization.put()

    # Load the current organization if defined (url, cookie or first)
    @onAppInit = (user, dhbRefId = null) ->
      # if there is no organization, then by default we show the account tab
      if user.organizations.length == 0
        $state.go('home.account')

      # Attempt to load organization from param
      if dhbRefId
        _self.selectedId = parseInt(dhbRefId)
        $log.debug "MnoeOrganizations.onAppInit: dhbRefId", _self.selectedId
        _self.get(_self.selectedId)

      # Attempt to load last organization from cookie
      else if (val = $cookies.get('dhb_ref_id'))
        _self.selectedId = parseInt(val)
        $log.debug "MnoeOrganizations.onAppInit: cookie", _self.selectedId
        _self.get(_self.selectedId)

      # Load first organization one otherwise
      else
        organization = user.organizations[0]
        _self.selectedId = organization.id
        $log.debug "MnoeOrganizations.onAppInit: first", _self.selectedId
        _self.get(organization.id)

    return @
