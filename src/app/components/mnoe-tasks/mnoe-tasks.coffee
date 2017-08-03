angular.module('mnoEnterpriseAngular').component('mnoeTasks', {
  bindings: {
  },
  templateUrl: 'app/components/mnoe-tasks/mnoe-tasks.html',
  controller: ($filter, $uibModal, $log, $translate, toastr, MnoeTasks)->
    ctrl = this

    ctrl.$onInit = ->
      ctrl.tasks = []
      ctrl.menus = [
        { label: $translate.instant('mno_enterprise.templates.components.mnoe-tasks.menus.inbox'), name: 'inbox', selected: true }
        { label: $translate.instant('mno_enterprise.templates.components.mnoe-tasks.menus.sent'), name: 'sent', query: { outbox: true } }
        { label: $translate.instant('mno_enterprise.templates.components.mnoe-tasks.menus.draft'), name: 'draft', query: { 'where[status][]': 'draft', outbox: true } }
      ]
      ctrl.tasksFilters = [
        { name: $translate.instant('mno_enterprise.templates.components.mnoe-tasks.tasks_filters.all_tasks_and_msgs') }
        { name: $translate.instant('mno_enterprise.templates.components.mnoe-tasks.tasks_filters.all_tasks'), query: { 'where[due_date.ne]': '' } }
        { name: $translate.instant('mno_enterprise.templates.components.mnoe-tasks.tasks_filters.all_messages'), query: { 'where[due_date.eq]': '' } }
        { name: $translate.instant('mno_enterprise.templates.components.mnoe-tasks.tasks_filters.due_tasks'), query: { 'where[due_date.lt]': moment().toISOString() } }
        { name: $translate.instant('mno_enterprise.templates.components.mnoe-tasks.tasks_filters.completed_tasks'), query: { 'where[completed_at.ne]': '' } }
      ]
      ctrl.selectedTasksFilter = ctrl.tasksFilters[0]
      ctrl.selectedMenu = _.find(ctrl.menus, (m)-> m.selected)
      loadTasks()

    ctrl.onSelectFilter = ({filter})->
      return if filter == ctrl.selectedTasksFilter
      ctrl.selectedTasksFilter = filter
      loadTasks()

    # Note: this gets called on mno-tasks-menu cmp init
    ctrl.onSelectMenu = ({menu})->
      return if menu == ctrl.selectedMenu
      ctrl.selectedMenu = menu
      loadTasks()

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

    ctrl.openShowTaskModal = ({rowItem})->
      task = rowItem
      modalInstance = $uibModal.open({
        component: 'mnoShowTaskModal'
        resolve:
          task: -> task
      })
      modalInstance.result.then(({reply, done})->
        task.markedDone = done if done?
        ctrl.sendReply(reply, task) if reply?
      )

    ctrl.sendReply = (reply, task) ->
      console.log('Sending reply.. ', reply, task)

    # Private

    loadTasks = (params = {})->
      # TODO: add loading for mnoSortingTable to remove the need to clear the tasks to improve UI glitchyness.
      ctrl.tasks.length = 0
      updateTasksTable()
      angular.merge(params, ctrl.selectedMenu.query, ctrl.selectedTasksFilter.query)
      MnoeTasks.get(params).then(
        (tasks)->
          ctrl.tasks = tasks
        (errors)->
          $log.error(errors)
          toastr.error('mno_enterprise.templates.components.mnoe-tasks.toastr_error.update')
      )

    updateTasksTable = ->
      firstColumn = if ctrl.selectedMenu.name == 'sent'
        { header: $translate.instant('mno_enterprise.templates.components.mnoe-tasks.tasks.column_label.to'), attr: 'task_recipients[0].user.name' }
      else
        { header: $translate.instant('mno_enterprise.templates.components.mnoe-tasks.tasks.column_label.from'), attr: 'owner.user.name' }
      ctrl.mnoSortableTableFields = [
        firstColumn
        { header: $translate.instant('mno_enterprise.templates.components.mnoe-tasks.tasks.column_label.title'), attr: 'title' }
        { header: $translate.instant('mno_enterprise.templates.components.mnoe-tasks.tasks.column_label.message'), attr: 'message', class: 'ellipsis' }
        { header: $translate.instant('mno_enterprise.templates.components.mnoe-tasks.tasks.column_label.received'), attr: 'send_at', filter: { run: $filter('date'), opts: ['medium'] } }
        { header: $translate.instant('mno_enterprise.templates.components.mnoe-tasks.tasks.column_label.due_date'), attr: 'due_date', filter: { run: $filter('date'), opts: ['medium'] } }
        { header: $translate.instant('mno_enterprise.templates.components.mnoe-tasks.tasks.column_label.done'), attr: 'markedDone', render: taskDoneCustomField, stopPropagation: true }
      ]

    # Callback for building a custom "done" checkbox field in the mnoSortableTable component.
    taskDoneCustomField = (rowItem)->
      # If a :completed_at timestamp exist, initialise frontend switch model for checkbox.
      rowItem.markedDone = rowItem.completed_at?
      {
        scope:
          markDone: (task)->
            status = if task.markedDone then 'sent' else 'done'
            MnoeTasks.update(task.id, status: status).then(
              (updatedTask)->
                angular.extend(task, updatedTask)
              (errors)->
                $log.error(errors)
                toastr.error('mno_enterprise.templates.components.mnoe-tasks.toastr_error.update')
            )
        template: """
          <input type="checkbox" class="toggle-task-done" ng-if="rowItem.due_date" ng-model="rowItem.markedDone" ng-change="markDone(rowItem)">
          <span ng-if="!rowItem.due_date">-</span>
        """
      }

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
