# Service for managing the users.
angular.module 'mnoEnterpriseAngular'
  .service 'MnoeOrganizations', ($cookies, MnoeApiSvc, MnoeCurrentUser) ->
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
      MnoeApiSvc.one('organizations', id).get().then(
        (response) ->
          _self.selected = response
          _self.selectedId = response.id
          $cookies.put('dhb_ref_id', response.id)
          console.log('selected organization', response)
          response
      )

    @create = (organization) ->
      organizationsApi.post(organization)

    @update = (organization) ->
      organization.put()

    # Load the current organization if defined (url, cookie or first)
    @onAppInit = (user, dhbRefId = null) ->
      # Attempt to load organization from param
      if dhbRefId
        _self.selectedId = parseInt(dhbRefId)
        console.log "MnoeOrganizations.onAppInit: dhbRefId", _self.selectedId
        _self.get(organization.id)

      # Attempt to load last organization from cookie
      else if (val = $cookies.get('dhb_ref_id'))
        _self.selectedId = parseInt(val)
        console.log "MnoeOrganizations.onAppInit: cookie", _self.selectedId
        _self.get(_self.selectedId)

      # Load first organization one otherwise
      else if user.organizations.length > 0
        organization = user.organizations[0]
        _self.selectedId = organization.id
        console.log "MnoeOrganizations.onAppInit: first", _self.selectedId
        _self.get(organization.id)

      # if the selectBox is empty, then by default we show the account tab
      else
        $location.path('/account')

      # # Attempt to load organization from param
      # # TODO: will not work with $stateParam, need to find a workaround
      # if (val = $stateParams.dhbRefId)
      #   val = parseInt(val)
      #   $location.search('dhbRefId', null)
      #   selectBox.organization = _.findWhere(selectBox.organizations, {id: val})
      #
      # # Attempt to load last organization from cookie
      # if !selectBox.organization? && (val = $cookies.get('dhb_ref_id'))
      #   selectBox.organization = _.findWhere(selectBox.organizations, {id: val})
      #
      # # Default to first one otherwise
      # unless selectBox.organization?
      #   selectBox.organization = selectBox.organizations[0]

      # # if the selectBox is empty, then by default we show the account tab
      # # note: That condition will be true when a reseller has just signed up after
      # # accepting an invitation to join a reseller organization. At that stage
      # # he may not have any customers and he won't have any personal organization.
      # if !(selectBox.organization && selectBox.organization.id)
      #   $location.path('/account')
      # else
      #   # otherwise we change the selectbox to the organization loaded
      #   selectBox.changeTo(selectBox.organization)

    return @
