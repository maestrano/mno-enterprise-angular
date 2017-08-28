# Service for managing the users.
angular.module 'mnoEnterpriseAngular'
  .service 'MnoeOrganizations', ($location, $state, $cookies, $log, $q, MnoeApiSvc, MnoeCurrentUser) ->
    _self = @

    organizationsApi = MnoeApiSvc.all('organizations')

    # Store the selected entity id
    # Mostly used to refresh the UI before the selected entity is requested
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

    organizationPromise = null
    @get = (id = null) ->
      # return the cached promise if not a new call
      return organizationPromise if ((!id? || id == _self.selectedId) && organizationPromise?)

      # Fetch user
      organizationPromise = MnoeCurrentUser.get().then(
        (response) ->
          # Fetch current organization
          _self.selectedId = if id? then id else $cookies.get("#{response.id}_dhb_ref_id")

          # Get the selected organization
          MnoeApiSvc.one('/organizations', _self.selectedId).get().then(
            (responseOrga) ->
              # Use user id to avoid another user to load with an unknown organisation
              $cookies.put("#{response.id}_dhb_ref_id", responseOrga.organization.id)

              # Save the organization in the service
              _self.selected = responseOrga.plain()
          )
      )

      return organizationPromise

    @create = (organization) ->
      MnoeApiSvc.all('/organizations').post(organization).then(
        (response) ->
          deferred = $q.defer()

          # Reload the permission table
          MnoeCurrentUser.refresh().then(
            ->
              # The promise is resolved and
              # return the newly created organisation
              deferred.resolve(response.organization)
          )

          deferred.promise
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

    # Add a new instance of an app
    @purchaseApp = (app, orgId = _self.selectedId) ->
      MnoeApiSvc.one('organizations', orgId).all('/app_instances').post({nid: app.nid}).then(
        (response) ->
          # Change current organization if another one has been selected
          _self.get(orgId)
          response
      )

    # Accept an array of invites
    # [{ email: 'bla@bla.com', role: 'Admin' }]
    # Or
    # a single email address
    # Or
    # a an array of email addresses
    # Or
    # a newline separated list of email addresses
    @inviteMembers = (invites) ->
      baseList = []
      if angular.isString(invites)
        baseList = invites.split("\n")
      else
        baseList = invites

      finalList = []
      _.each baseList, (e) ->
        if angular.isObject(e)
          finalList.push(e)
        else
          finalList.push({email: e})

      data = { invites: finalList }
      MnoeApiSvc.one('organizations', _self.selectedId).doPUT(data, '/invite_members').then(
        (response) ->
          response.members
      )

    @updateMember = (member) ->
      data = { member: member }
      MnoeApiSvc.one('organizations', _self.selectedId).doPUT(data, '/update_member').then(
        (response) ->
          # Update the current user role if it was changed
          if member.email == _self.selected.current_user.email
            _self.selected.current_user.role = member.role
          # Return the list of members
          response.members
      )

    @deleteMember = (member) ->
      data = { member: _.pick(member, "email") }
      MnoeApiSvc.one('organizations', _self.selectedId).doPUT(data, '/remove_member').then(
        (response) ->
          response.members
      )

    # Load the current organization if defined (url, cookie or first)
    @getCurrentOrganisation = () ->
      defer = $q.defer()

      dhbRefId = $location.search().dhbRefId
      $location.search('dhbRefId', null)

      # Attempt to load organization from param
      if dhbRefId
        $log.debug "MnoeOrganizations.getCurrentOrganisation: dhbRefId", dhbRefId
        _self.get(dhbRefId).then((response) -> defer.resolve(response))
      else
        # Load user's first organization or from cookie
        MnoeCurrentUser.get().then(
          (response) ->
            return unless response.logged_in
            defer.reject() if response.organizations.length == 0

            val = $cookies.get("#{response.id}_dhb_ref_id")
            if val?
              # Load organization id stored in cookie
              $log.debug "MnoeOrganizations.getCurrentOrganisation: cookie", val
              _self.get(val).then((response) -> defer.resolve(response))
            else if response.organizations.length > 0
              # Load user's first organization id
              $log.debug "MnoeOrganizations.getCurrentOrganisation: first", response.organizations[0].id
              _self.get(response.organizations[0].id).then((response) -> defer.resolve(response))
            else
              defer.resolve(response)
        )

      return defer.promise

    #======================================
    # User Role
    #======================================
    @role = {}

    _self.role.isSuperAdmin = (role) ->
      return role == 'Super Admin' if role
      _self.selected? && _self.selected.current_user? && _self.selected.current_user.role == 'Super Admin'

    _self.role.isAdmin = (role) ->
      return role == 'Admin' if role
      _self.selected? && _self.selected.current_user? && _self.selected.current_user.role == 'Admin'

    _self.role.isPowerUser = (role) ->
      return role == 'Power User' if role
      _self.selected? && _self.selected.current_user? && _self.selected.current_user.role == 'Power User'

    _self.role.isMember = (role) ->
      return role == 'Member' if role
      _self.selected? && _self.selected.current_user? && _self.selected.current_user.role == 'Member'

    _self.role.atLeastMember = ->
      true

    _self.role.atLeastPowerUser = (role) ->
      _self.role.isPowerUser(role) || _self.role.isAdmin(role) || _self.role.isSuperAdmin(role)

    _self.role.atLeastAdmin = (role) ->
      _self.role.isAdmin(role) || _self.role.isSuperAdmin(role)

    _self.role.atLeastSuperAdmin = (role) ->
      _self.role.isSuperAdmin(role)

    #======================================
    # Access Management
    #======================================
    @can = {}

    _self.can.read = {
      appInstance: -> _self.role.atLeastMember()
      billing: -> _self.role.atLeastSuperAdmin()
      member: -> _self.role.atLeastMember()
      organizationSettings: -> _self.role.atLeastSuperAdmin()
    }

    _self.can.create = {
      appInstance: -> _self.role.atLeastAdmin()
      billing: -> _self.role.atLeastSuperAdmin()
      member: (obj = null) -> _self.role.atLeastAdmin() && (obj == null || obj.role != 'Super Admin' || _self.role.isSuperAdmin())
      organizationSettings: -> _self.role.atLeastSuperAdmin()
    }

    _self.can.update = {
      appInstance: (obj = null) -> _self.can.create.appInstance(obj) # call similar permission
      billing: (obj = null) -> _self.can.create.billing(obj) # call similar permission
      member: (obj = null) -> _self.can.create.member(obj) && (obj.role != 'Super Admin' || _self.role.isSuperAdmin())
      organizationSettings: (obj = null) -> _self.can.create.organizationSettings(obj) # call similar permission
    }

    _self.can.destroy = {
      appInstance: (obj = null) -> _self.can.create.appInstance(obj) # call similar permission
      billing: (obj = null) -> _self.can.create.billing(obj) # call similar permission
      member: (obj = null) -> _self.can.create.member(obj) && (obj.role != 'Super Admin' || _self.role.isSuperAdmin())
      organizationSettings: (obj = null) -> _self.can.create.organizationSettings(obj) # call similar permission
    }

    _self.can.connect = {
      appInstance: -> _self.role.atLeastAdmin()
    }

    return @
