angular.module('mnoEnterpriseAngular').component('connectAddonModal', {
  bindings: {
    resolve: '<'
    close: '&',
    dismiss: '&'
  },
  templateUrl: 'app/components/connect-addon-modal/connect-addon-modal.html',
  controller: (MnoeAppInstances, toastr, $translate) ->

    ctrl = this

    ctrl.app = null
    ctrl.model = {}
    ctrl.isFormLoading = true
    ctrl.isSubmitting = false
    ctrl.historicalData = false
    ctrl.date = new Date()

    ctrl.$onInit = ->
      ctrl.app = ctrl.resolve.app
      ctrl.currentStep = if ctrl.app.addon_organization.has_account_linked then 1 else 0
      MnoeAppInstances.getForm(ctrl.app).then((response) ->
        ctrl.schema = response.schema
        ctrl.form = [ "*" ]
        ctrl.isFormLoading = false
      )

    ctrl.submitForm = () ->
      ctrl.isSubmitting = true
      MnoeAppInstances.submitForm(ctrl.app, ctrl.model).then((response) ->
        if response.linking_error
          toastr.error(response.linking_error)
        else
          ctrl.app.addon_organization.has_account_linked = true
          ctrl.currentStep = 1
      ).finally(-> ctrl.isSubmitting = false)

    ctrl.unselectEntities = ->
      ctrl.currentStep = 1

    ctrl.forceSelectEntities = ->
      ctrl.currentStep = 2

    ctrl.updateEntities = ->
      ctrl.isUpdating = true
      synchronizedEntities = {}
      _.forOwn ctrl.app.addon_organization.displayable_synchronized_entities, (value, key) ->
        synchronizedEntities[key] = _.pick(value, [
          'can_push_to_connec'
          'can_push_to_external'
        ])
      MnoeAppInstances.updateEntities(ctrl.app, synchronizedEntities, ctrl.app.addon_organization.id).then((response) ->
        ctrl.currentStep = 2
        ctrl.isUpdating = false
      )

    ctrl.backClick = ->
      switch ctrl.currentStep
        when 1 then ctrl.disconnect()
        when 2 then ctrl.unselectEntities()

    ctrl.nextClick = ->
      switch ctrl.currentStep
        when 0 then ctrl.submitForm()
        when 1 then ctrl.updateEntities()
        when 2 then ctrl.synchronize(ctrl.historicalData)

    ctrl.disconnect = ->
      ctrl.isDisconnecting = true
      MnoeAppInstances.disconnect(ctrl.app)
        .then((response) ->
          ctrl.app.addon_organization.has_account_linked = false
          ctrl.app.addon_organization.sync_enabled = false
          ctrl.currentStep = 0
          ctrl.isDisconnecting = false
        )

    ctrl.synchronize = (historicalData) ->
      MnoeAppInstances.sync(ctrl.app, historicalData)
      ctrl.app.addon_organization.sync_enabled = true
      ctrl.close()
      $translate('mno_enterprise.templates.components.addon_connect.sync.sync_launched').then((tls) ->
        toastr.success(tls)
      )

    return
})
