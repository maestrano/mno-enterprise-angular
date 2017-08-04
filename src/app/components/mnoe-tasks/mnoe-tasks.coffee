angular.module('mnoEnterpriseAngular').component('mnoeTasks', {
  bindings: {
  },
  templateUrl: 'app/components/mnoe-tasks/mnoe-tasks.html',
  controller: ($filter, $uibModal, $log, $translate, $timeout, toastr, MnoeTasks)->
    ctrl = this
    ctrl.$onInit = ->
      ctrl.tasks = {
        list: []
        sort: 'send_at.desc'
        nbItems: 10
        offset: 0
        page: 1
        loading: false
        pageChangedCb: (nbItems, page) ->
          ctrl.tasks.nbItems = nbItems
          ctrl.tasks.page = page
          ctrl.tasks.offset = (page  - 1) * nbItems
          fetchTasks(limit: nbItems, offset: ctrl.tasks.offset)
      }
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
      fetchTasks()

    ctrl.onSelectFilter = ({filter})->
      return if filter == ctrl.selectedTasksFilter
      ctrl.selectedTasksFilter = filter
      fetchTasks()

    ctrl.onSelectMenu = ({menu})->
      return if menu == ctrl.selectedMenu
      ctrl.selectedMenu = menu
      fetchTasks()

    ctrl.openCreateTaskModal = ->
      modalInstance = $uibModal.open({
        component: 'mnoCreateTaskModal'
        resolve:
          recipients: MnoeTasks.getRecipients()
      })
      modalInstance.result.then(({isDraft, newTask})->
        newTask.status = if isDraft then 'draft' else 'sent'
        createTask(newTask)
      )

    ctrl.openShowTaskModal = ({rowItem})->
      task = rowItem
      modalInstance = $uibModal.open({
        component: 'mnoShowTaskModal'
        resolve:
          task: -> task
          dateFormat: -> 'MMM d, yyyy, h:mma'
      })
      modalInstance.result.then(({reply, done})->
        (task.markedDone = done) & updateTask(task) if done?
        ctrl.sendReply(reply, task) if reply?
      )

    ctrl.sendReply = (reply, task) ->
      angular.merge(reply, { title: "RE: #{task.title}", orga_relation_id: task.owner_id, status: 'sent' })
      createTask(reply)

    # Manage sorting for mnoSortableTable with angular-smart-table st-pipe.
    ctrl.sortableTableServerPipe = (tableState)->
      ctrl.tasks.sort = updateSort(tableState.sort)
      fetchTasks(limit: ctrl.tasks.nbItems, offset: ctrl.tasks.offset, order_by: ctrl.tasks.sort)

    # Update angular-smart-table sorting parameters
    updateSort = (sortState = {}) ->
      sort = ctrl.tasks.sort
      if sortState.predicate
        sort = sortState.predicate
        if sortState.reverse
          sort += ".desc"
        else
          sort += ".asc"
      return sort

    # Private

    fetchTasks = (params)->
      ctrl.tasks.loading = true
      params ||= { limit: ctrl.tasks.nbItems, offset: ctrl.tasks.offset, order_by: ctrl.tasks.sort }
      angular.merge(params, ctrl.selectedMenu.query, ctrl.selectedTasksFilter.query)
      updateTasksTable()
      MnoeTasks.get(params).then(
        (response)->
          ctrl.tasks.list = response.data.plain()
          ctrl.tasks.totalItems = response.headers('x-total-count')
        (errors)->
          $log.error(errors)
          toastr.error('mno_enterprise.templates.components.mnoe-tasks.toastr_error.get_tasks')
      ).finally(->
        # Add delay to improve UI the rendering appearance while new data is bound.
        $timeout(->
          ctrl.tasks.loading = false
        , 250)
      )

    createTask = (task)->
      MnoeTasks.create(task).then(
        ->
          fetchTasks()
        (errors)->
          $log.error(errors)
          toastr.error('mno_enterprise.templates.components.mnoe-tasks.toastr_error.create_task')
      )

    updateTask = (task, params = {})->
      params.status = if task.markedDone then 'done' else 'sent'
      MnoeTasks.update(task.id, params).then(
        (updatedTask)->
          angular.extend(task, updatedTask)
        (errors)->
          $log.error(errors)
          toastr.error('mno_enterprise.templates.components.mnoe-tasks.toastr_error.update_task')
      )

    updateTasksTable = ->
      firstColumn = if ctrl.selectedMenu.name == 'sent'
        { header: $translate.instant('mno_enterprise.templates.components.mnoe-tasks.tasks.column_label.to'), attr: 'task_recipients[0].user.name' }
      else
        { header: $translate.instant('mno_enterprise.templates.components.mnoe-tasks.tasks.column_label.from'), attr: 'owner.user.name' }
      ctrl.mnoSortableTableFields = [
        firstColumn
        { header: $translate.instant('mno_enterprise.templates.components.mnoe-tasks.tasks.column_label.title'), attr: 'title', class: 'ellipsis' }
        { header: $translate.instant('mno_enterprise.templates.components.mnoe-tasks.tasks.column_label.message'), attr: 'message', class: 'ellipsis' }
        { header: $translate.instant('mno_enterprise.templates.components.mnoe-tasks.tasks.column_label.received'), attr: 'send_at', filter: { run: $filter('date'), opts: ['MMM d, yyyy, h:mma'] } }
        { header: $translate.instant('mno_enterprise.templates.components.mnoe-tasks.tasks.column_label.due_date'), attr: 'due_date', filter: { run: $filter('date'), opts: ['MMM d, yyyy, h:mma'] } }
        { header: $translate.instant('mno_enterprise.templates.components.mnoe-tasks.tasks.column_label.done'), attr: 'completed_at', render: taskDoneCustomField, stopPropagation: true }
      ]

    # Callback for building a custom "done" checkbox field in the mnoSortableTable component.
    taskDoneCustomField = (rowItem)->
      # If a :completed_at timestamp exist, initialise frontend switch model for checkbox.
      rowItem.markedDone = rowItem.completed_at?
      {
        scope:
          markDone: (task)-> updateTask(task)
        template: """
          <input type="checkbox" class="toggle-task-done" ng-if="rowItem.due_date" ng-model="rowItem.markedDone" ng-change="markDone(rowItem)">
          <span ng-if="!rowItem.due_date">-</span>
        """
      }

    ctrl
})
