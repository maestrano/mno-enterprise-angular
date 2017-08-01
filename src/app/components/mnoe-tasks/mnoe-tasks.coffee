angular.module('mnoEnterpriseAngular').component('mnoeTasks', {
  bindings: {
  },
  templateUrl: 'app/components/mnoe-tasks/mnoe-tasks.html',
  controller: ($filter, $uibModal)->
    ctrl = this

    ctrl.$onInit = ->
      ctrl.tasks = getTasks()
      ctrl.mnoSortableTableFields = [
        { header: 'From', attr: 'recipient.name' }
        { header: 'Title', attr: 'title' }
        { header: 'Message', attr: 'message' }
        { header: 'Received', attr: 'send_at', filter: { run: $filter('date'), opts: ['medium'] } }
        { header: 'Due date', attr: 'due_date', filter: { run: $filter('date'), opts: ['medium'] } }
        { header: 'Done', attr: 'markedDone', render: -> taskDoneCustomField() }
      ]

    taskDoneCustomField = ->
      scope:
        markDone: (task)->
          console.log 'mark done! ', task
      template: """
        <input type="checkbox" class="toggle-task-done" ng-if="data.due_date" ng-model="data.markedDone" ng-change="markDone(data)">
        <span ng-if="!data.due_date">-</span>
      """

    ctrl.openCreateTaskModal = ->
      modalInstance = $uibModal.open({
        component: 'mnoCreateTaskModal'
        resolve:
          recipients: -> getRecipients()
      })
      modalInstance.result.then(({isDraft, newTask})->
        if isDraft
          console.log('save task as draft: ', newTask)
        else
          console.log('send task: ', newTask)
      )

    getTasks = ->
      [
        {
            "id": 49,
            "owner_id": 99,
            "recipient": {
              "name": "Eduardo"
            },
            "title": "A Payment due",
            "message": "Hi Eduardo, please pay me mate.",
            "send_at": "2017-07-18T11:47:44.000Z",
            "status": "draft",
            "due_date": "2017-07-18T11:47:44.000Z",
            "completed_at": "2017-07-18T11:47:44.000Z",
            "completed_notified_at": "2017-07-18T11:47:44.000Z",
            "created_at": "2017-07-26T17:47:10.000Z",
            "updated_at": "2017-07-26T17:47:31.000Z"
        },
        {
            "id": 53,
            "owner_id": 99,
            "recipient": {
              "name": "Marco"
            },
            "title": "B Group entities",
            "message": "Hi Marco, group the entities asap.",
            "send_at": "2017-07-18T11:47:44.000Z",
            "status": "sent",
            "due_date": "2017-07-18T11:47:44.000Z",
            "completed_at": "2017-07-18T11:47:44.000Z",
            "completed_notified_at": "2017-07-18T11:47:44.000Z",
            "created_at": "2017-07-27T08:25:41.000Z",
            "updated_at": "2017-07-27T08:26:05.000Z"
        },
        {
            "id": 55,
            "owner_id": 99,
            "recipient": {
              "name": "Manu"
            },
            "title": "A really cool dude",
            "message": "Hi Manu, do cool stuff.",
            "send_at": "2017-07-18T11:47:44.000Z",
            "status": "sent",
            "due_date": null,
            "completed_at": "2017-07-18T11:47:44.000Z",
            "completed_notified_at": "2017-07-18T11:47:44.000Z",
            "created_at": "2017-07-27T08:25:41.000Z",
            "updated_at": "2017-07-27T08:26:05.000Z"
        }
      ]

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
