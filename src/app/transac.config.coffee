angular.module 'mnoEnterpriseAngular'

.run((TransacUserService, ImpacConfigSvc)->

  TransacUserService.configure(
    user: ImpacConfigSvc.getUserData
    organizations: ImpacConfigSvc.getOrganizations
  )
)
