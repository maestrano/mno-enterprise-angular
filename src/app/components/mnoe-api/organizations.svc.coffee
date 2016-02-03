# Service for managing the users.
angular.module 'mnoEnterpriseAngular'
  .service 'MnoeOrganizations', ($state, $cookies, $log, $q, MnoeApiSvc, MnoeCurrentUser) ->
    _self = @

    organizationsApi = MnoeApiSvc.all('organizations')

    # Store the selected entity id
    # Mostly used to refresh the UI befor the selected entity is requested
    @selectedId = null

    @getSelectedId = ->
      _self.selectedId

    # Store the selected entity
    @selected = null

    @getSelected = ->
      _self.selected

    @list = () ->
      organizationsApi.getList().then(
        (response) ->
          _self.list = response
          response
      )

    @get = (id) ->
      return if id == _self.selectedId

      _self.selectedId = id

      # Get the selected organization
      organizationPromise = MnoeApiSvc.one('/organizations', id).get().then(
        (response) ->
          # Save the organization
          _self.selected = response.plain()
          $cookies.put('dhb_ref_id', _self.selectedId)
          response
      )

    @create = (organization) ->
      MnoeApiSvc.all('/organizations').post(organization).then(
        (response) ->
          # Add the new org in the menu
          _self.selectedId = _self.selected.organization.id
          MnoeCurrentUser.user.organizations.push(response.plain().organization)

          # Reload the permissions
          MnoeCurrentUser.refresh().then(
            ->
              _self.selected = response.plain()
              _self.selectedId = _self.selected.organization.id
          )

          response
      )

    # TODO: Standardize API tobe able to use Restangular default behaviour (_self.selected.put())
    @update = (organization) ->
      payload = { organization: organization }
      MnoeApiSvc.one('/organizations', _self.selectedId).customPUT(payload).then(
        (response) ->
          response = response.plain()
          # Update the selected organisation
          angular.extend(_self.selected.organization, response.organization)

          # Update the organisation in user organisations list
          angular.extend(_.find(MnoeCurrentUser.user.organizations, { id: response.organization.id }), response.organization)

          response
      )

    # Update the credit card
    @updateCreditCard = (creditCard) ->
      MnoeApiSvc.one('organizations', _self.selectedId).doPUT({"credit_card": creditCard}, '/update_billing').then(
        (response) ->
          # Return an unrestangularized object
          # as the API doesn't return a standardized object
          # TODO: Change API
          response.plain()
      )

    # Load the current organization if defined (url, cookie or first)
    @getCurrentId = (user = null, dhbRefId = null) ->
      # Return the already selected id
      if _self.selectedId
        $log.debug "MnoeOrganizations.getCurrentId: selectedId", _self.selectedId
        return _self.selectedId

      # Attempt to load organization from param
      else if dhbRefId
        _self.get(dhbRefId)
        $log.debug "MnoeOrganizations.getCurrentId: dhbRefId", _self.selectedId
        return dhbRefId

      # Attempt to load last organization from cookie
      else if (val = $cookies.get('dhb_ref_id'))
        _self.get(val)
        $log.debug "MnoeOrganizations.getCurrentId: cookie", _self.selectedId
        return val

      # Load first organization from user
      else
        # If the app is initializing, return the correct organization id
        organization = user.organizations[0]
        _self.get(organization.id)
        $log.debug "MnoeOrganizations.getCurrentId: first", _self.selectedId
        return organization.id

    #======================================
    # User Role
    #======================================
    @role = {}

    _self.role.isSuperAdmin = ->
      _self.selected? && _self.selected.current_user.role == 'Super Admin'

    _self.role.isAdmin = ->
      _self.selected? && _self.selected.current_user.role == 'Admin'

    _self.role.isPowerUser = ->
      _self.selected? && _self.selected.current_user.role == 'Power User'

    _self.role.isMember = ->
      _self.selected? && _self.selected.current_user.role == 'Member'

    _self.role.atLeastMember = ->
      true

    _self.role.atLeastPowerUser = ->
      _self.role.isPowerUser() || _self.role.isAdmin() || _self.role.isSuperAdmin()

    _self.role.atLeastAdmin = ->
      _self.role.isAdmin() || _self.role.isSuperAdmin()

    _self.role.atLeastSuperAdmin = ->
      _self.role.isSuperAdmin()

    #======================================
    # Access Management
    #======================================
    @can = {}

    _self.can.read = {
      appInstance: (obj = null) -> _self.role.atLeastMember()
      billing: (obj = null) -> _self.role.atLeastSuperAdmin()
      member: (obj = null) -> _self.role.atLeastMember()
      organizationSettings: (obj = null) -> _self.role.atLeastSuperAdmin()
    }

    _self.can.create = {
      appInstance: (obj = null) -> _self.role.atLeastAdmin()
      billing: (obj = null) -> _self.role.atLeastSuperAdmin()
      member: (obj = null) -> _self.role.atLeastAdmin() && (obj == null || obj.role != 'Super Admin' || _self.role.isSuperAdmin())
      organizationSettings: (obj = null) -> _self.role.atLeastSuperAdmin()
    }

    _self.can.update = {
      appInstance: (obj = null) -> _self.can.create.appInstance(obj) # call similar permission
      billing: (obj = null) -> _self.can.create.billing(obj) # call similar permission
      member: (obj = null) -> _self.can.create.member(obj) # call similar permission
      organizationSettings: (obj = null) -> _self.can.create.organizationSettings(obj) # call similar permission
    }

    _self.can.destroy = {
      appInstance: (obj = null) -> _self.can.create.appInstance(obj) # call similar permission
      billing: (obj = null) -> _self.can.create.billing(obj) # call similar permission
      member: (obj = null) -> _self.can.create.member(obj) # call similar permission
      organizationSettings: (obj = null) -> _self.can.create.organizationSettings(obj) # call similar permission
    }

    return @
