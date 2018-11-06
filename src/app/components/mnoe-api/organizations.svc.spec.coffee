describe('Service: MnoeOrganizations', ->

  beforeEach(module('mnoEnterpriseAngular'))

  $httpBackend = null
  MnoeOrganizations = null

  beforeEach(inject((_MnoeOrganizations_, _$httpBackend_) ->
    MnoeOrganizations = _MnoeOrganizations_
    $httpBackend = _$httpBackend_

    # Global stubs
    $httpBackend.when('GET', 'locales/en.json').respond(200)
    $httpBackend.when('GET', 'locales/en-AU.json').respond(200)

    $httpBackend.when('GET', '/mnoe/jpi/v1/current_user').respond(200,
      {
        "current_user": {
          "id": 1,
          "logged_in": true,
          "organizations": [
            { "id": 9, "uid": "usr-fbbw", "name": "Marvel", "current_user_role": "Super Admin" }
          ]
        }
      })
    $httpBackend.when('GET', '/mnoe/jpi/v1/organizations/9/app_instances').respond(200,
      {
        "app_instances": {
          "811": {"id": "811", "uid": "cld-9ou5", "stack": "connector", "name": "Xero", "status": "running"}
        }
      }
    )

    # @list backend interceptor
    $httpBackend.when('GET', '/mnoe/jpi/v1/organizations').respond(200,
      {
        "organizations": [
          { "id": 9, "uid": "usr-fbbw", "name": "Marvel" },
          { "id": 10, "uid": "usr-fbb7", "name": "DC Comics" }
        ]
      })

    # @get backend interceptor
    $httpBackend.when('GET', '/mnoe/jpi/v1/organizations/9').respond(200,
      {
        "organization": [
          { "id": 9, "uid": "usr-fbbw", "name": "Marvel" }
        ]
      })

    # @get backend interceptor
    $httpBackend.when('GET', '/mnoe/jpi/v1/marketplace?organization_id=9').respond(200,
      {
        "apps": [
          { "id": 9, "uid": "app-abcd", "name": "My App" }
        ]
      })

    # # @update backend interceptor
    # $httpBackend.when('PUT', '/mnoe/jpi/v1/organizations/9').respond(200,
    #   {
    #     "organization": [
    #       { "id": 9, "uid": "usr-fbbw", "name": "Marvel" }
    #     ]
    #   })
  ))

  afterEach( ->
    $httpBackend.verifyNoOutstandingExpectation()
    $httpBackend.verifyNoOutstandingRequest()
  )

  describe('@list', ->
    it('GETs /mnoe/jpi/v1/organizations', ->
      $httpBackend.expectGET('/mnoe/jpi/v1/organizations')
      MnoeOrganizations.list()
      $httpBackend.flush()
    )
  )

  describe('@get', ->
    it('GETs /mnoe/jpi/v1/organizations/9', ->
      $httpBackend.expectGET('/mnoe/jpi/v1/organizations/9')
      MnoeOrganizations.get(9)
      $httpBackend.flush()
    )
  )

  # describe('@update', ->
  #   it('PUTs /mnoe/jpi/v1/organizations/9', ->
  #     $httpBackend.expectPUT('/mnoe/jpi/v1/organizations/9')
  #
  #     org = "organization": [
  #       { "id": 9, "uid": "usr-fbbw", "name": "Marvel" }
  #     ]
  #
  #     MnoeOrganizations.update(org)
  #     $httpBackend.flush()
  #   )
  # )
)
