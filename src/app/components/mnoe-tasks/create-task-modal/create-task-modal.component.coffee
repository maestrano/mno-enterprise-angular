angular.module('mnoEnterpriseAngular').component('createTaskModal', {
  bindings: {
    close: '&',
    dismiss: '&'
  },
  templateUrl: 'app/components/mnoe-tasks/create-task-modal/create-task-modal.html',
  controller: ()->
    ctrl = this

    ctrl.$onInit = ->
      ctrl.newTask = {}
      ctrl.recipients = getRecipients()

    ctrl.ok = (isDraft = false)->
      ctrl.close($value: { isDraft: isDraft, newTask: ctrl.newTask})

    ctrl.cancel = ->
      ctrl.dismiss()

    getRecipients = ->
      [
        { user: { name: 'Eduardo' }, organization: { name: 'Maestrano' } }
        { user: { name: 'Manu' }, organization: { name: 'Maestrano' } }
        { user: { name: 'Xaun' }, organization: { name: 'Maestrano' } }
        { user: { name: 'Marco' }, organization: { name: 'Maestrano' } }
        { user: { name: 'Xavier' }, organization: { name: 'Maestrano' } }
        { user: { name: 'Arnaud' }, organization: { name: 'Maestrano' } }
      ]

    ctrl
})
