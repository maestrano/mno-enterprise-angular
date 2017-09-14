angular.module('mnoEnterpriseAngular').component('mnoeTasks', {
  bindings: {
  },
  templateUrl: 'app/components/mnoe-tasks/mnoe-tasks.html',
  controller: ($filter, $uibModal, $translate, $timeout, $q, toastr, MnoErrorsHandler, MnoeTasks, MnoeCurrentUser)->
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
      $translate([
        'mno_enterprise.templates.components.mnoe-tasks.menus.inbox',
        'mno_enterprise.templates.components.mnoe-tasks.menus.sent',
        'mno_enterprise.templates.components.mnoe-tasks.menus.draft',
        'mno_enterprise.templates.components.mnoe-tasks.tasks_filters.all_tasks_and_msgs',
        'mno_enterprise.templates.components.mnoe-tasks.tasks_filters.all_tasks',
        'mno_enterprise.templates.components.mnoe-tasks.tasks_filters.all_messages',
        'mno_enterprise.templates.components.mnoe-tasks.tasks_filters.due_tasks',
        'mno_enterprise.templates.components.mnoe-tasks.tasks_filters.completed_tasks'
      ]).then((tls)->
        ctrl.menus = [
          { label: tls['mno_enterprise.templates.components.mnoe-tasks.menus.inbox'], name: 'inbox', selected: true }
          { label: tls['mno_enterprise.templates.components.mnoe-tasks.menus.sent'], name: 'sent', query: { 'where[status.ne][]': 'draft', outbox: true } }
          { label: tls['mno_enterprise.templates.components.mnoe-tasks.menus.draft'], name: 'draft', query: { 'where[status][]': 'draft', outbox: true } }
        ]
        ctrl.tasksFilters = [
          { name: tls['mno_enterprise.templates.components.mnoe-tasks.tasks_filters.all_tasks_and_msgs'] }
          { name: tls['mno_enterprise.templates.components.mnoe-tasks.tasks_filters.all_tasks'], query: { 'where[due_date.ne]': '' } }
          { name: tls['mno_enterprise.templates.components.mnoe-tasks.tasks_filters.all_messages'], query: { 'where[due_date.eq]': '' } }
          { name: tls['mno_enterprise.templates.components.mnoe-tasks.tasks_filters.due_tasks'], query: { 'where[due_date.lt]': moment.utc().toISOString(), 'where[status.ne]': 'done' } }
          { name: tls['mno_enterprise.templates.components.mnoe-tasks.tasks_filters.completed_tasks'], query: { 'where[completed_at.ne]': '' } }
        ]
        ctrl.selectedTasksFilter = ctrl.tasksFilters[0]
        ctrl.selectedMenu = _.find(ctrl.menus, (m)-> m.selected)
        fetchTasks()
      )

    ctrl.onSelectFilter = ({filter})->
      return if filter == ctrl.selectedTasksFilter
      ctrl.selectedTasksFilter = filter
      fetchTasks()

    ctrl.onSelectMenu = ({menu})->
      return if menu == ctrl.selectedMenu
      ctrl.selectedMenu = menu
      params = { order_by: 'updated_at.desc' } if menu.name == 'draft'
      fetchTasks(params)

    ctrl.onRefreshTasks = ->
      fetchTasks()

    ctrl.sortableTableRowOnClick = ({rowItem})->
      if ctrl.selectedMenu.name == 'draft' then ctrl.openCreateTaskModal(rowItem) else ctrl.openShowTaskModal(rowItem)

    ctrl.openCreateTaskModal = (task)->
      $uibModal.open({
        component: 'mnoCreateTaskModal'
        resolve:
          recipientFormatter: () -> nameFormatter
          draftTask: ->
            angular.copy(task) if task
          recipients: MnoeTasks.getRecipients()
          createTaskCb: ->
            (newTask) ->
              createTask(newTask)
          updateDraftCb: ->
            (draftTask)->
              updateTask(draftTask, draftTask).then(
                ->
                  fetchTasks()
              )
      })

    ctrl.openShowTaskModal = (task)->
      $uibModal.open({
        component: 'mnoShowTaskModal'
        resolve:
          task: -> angular.copy(task)
          isInbox: -> ctrl.selectedMenu.name == 'inbox'
          nameFormatter: () -> nameFormatter
          dueDateFormat: -> 'MMMM d'
          # $uibModal resolve internally unwraps the promise, applying the result to currentUser.
          currentUser: MnoeCurrentUser.get()
          setReminderCb: ->
            (reminderDate)->
              updateTask(task, reminder_date: reminderDate)
          onReadTaskCb: ->
            (hasBeenRead)->
              # Only mark inbox items that have no already been read as read.
              return $q.resolve() if hasBeenRead || ctrl.selectedMenu.name != 'inbox'
              updateTask(task, read_at: moment.utc().toISOString())
          markAsDoneCb: ->
            (isDone)->
              updateTaskStatus(task, isDone)
          sendReplyCb: ->
            (reply, markAsDone)->
              promise = if markAsDone then updateTaskStatus(task, markAsDone) else $q.resolve()
              promise.then(
                ->
                  ctrl.sendReply(reply, task)
              )
      })

    ctrl.sendReply = (reply, task) ->
      angular.merge(reply, { title: "RE: #{task.title}", orga_relation_id: task.owner_id, status: 'sent' })
      createTask(reply)

    # Manage sorting for mnoSortableTable with angular-smart-table st-pipe.
    ctrl.sortableTableServerPipe = (tableState)->
      ctrl.tasks.sort = updateTableSort(tableState.sort)
      fetchTasks(limit: ctrl.tasks.nbItems, offset: ctrl.tasks.offset, order_by: ctrl.tasks.sort)

    # Private

    nameFormatter = (orgaRel) ->
      "#{orgaRel.user.name} #{orgaRel.user.surname}"

    # Update angular-smart-table sorting parameters
    updateTableSort = (sortState = {}) ->
      sort = ctrl.tasks.sort
      if sortState.predicate
        sort = sortState.predicate
        if sortState.reverse
          sort += ".desc"
        else
          sort += ".asc"
      return sort

    fetchTasks = (params = {})->
      ctrl.tasks.loading = true
      buildMnoSortableTable()
      baseParams = { limit: ctrl.tasks.nbItems, offset: ctrl.tasks.offset, order_by: ctrl.tasks.sort }
      params = angular.merge({}, baseParams, params, ctrl.selectedMenu.query, ctrl.selectedTasksFilter.query)
      MnoeTasks.get(params).then(
        (response)->
          ctrl.tasks.list = response.data.plain()
          ctrl.tasks.totalItems = response.headers('x-total-count')
          ctrl.tasks.list
        (errors)->
          MnoErrorsHandler.processServerError(errors)
          toastr.error('mno_enterprise.templates.components.mnoe-tasks.toastr_error.get_tasks')
          return
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
          MnoErrorsHandler.processServerError(errors)
          toastr.error('mno_enterprise.templates.components.mnoe-tasks.toastr_error.create_task')
          return
      )

    updateTask = (task, params = {})->
      MnoeTasks.update(task.id, params).then(
        (updatedTask)->
          angular.extend(task, updatedTask)
        (errors)->
          MnoErrorsHandler.processServerError(errors)
          toastr.error('mno_enterprise.templates.components.mnoe-tasks.toastr_error.update_task')
          return
      )

    # Update Task status attribute & linked 'done' checkbox ngModel
    updateTaskStatus = (task, isDone)->
      task.markedDone = isDone
      status = if isDone then 'done' else 'sent'
      MnoeTasks.update(task.id, status: status).then(
        (response)->
          angular.extend(task, response)
        (errors)->
          MnoErrorsHandler.processServerError(errors)
          toastr.error('mno_enterprise.templates.components.mnoe-tasks.toastr_error.update_task')
          # Revert to previous state, as unchecked or checked on update fail
          task.markedDone = !task.markedDone
          return
      )

    # Creates mnoSortableTable cmp config API, building the tasks table columns
    buildMnoSortableTable = ->
      $translate([
        'mno_enterprise.templates.components.mnoe-tasks.tasks.column_label.user.name',
        'mno_enterprise.templates.components.mnoe-tasks.tasks.column_label.user.surname',
        'mno_enterprise.templates.components.mnoe-tasks.tasks.column_label.title',
        'mno_enterprise.templates.components.mnoe-tasks.tasks.column_label.message',
        'mno_enterprise.templates.components.mnoe-tasks.tasks.column_label.received',
        'mno_enterprise.templates.components.mnoe-tasks.tasks.column_label.sent',
        'mno_enterprise.templates.components.mnoe-tasks.tasks.column_label.read',
        'mno_enterprise.templates.components.mnoe-tasks.tasks.column_label.updated_at',
        'mno_enterprise.templates.components.mnoe-tasks.tasks.column_label.due_date',
        'mno_enterprise.templates.components.mnoe-tasks.tasks.column_label.done'
      ]).then((tls)->
        toUserNameColumn = { header: tls['mno_enterprise.templates.components.mnoe-tasks.tasks.column_label.user.name'], attr: 'task_recipients[0].user.name'}
        toUserSurnameColumn = { header: tls['mno_enterprise.templates.components.mnoe-tasks.tasks.column_label.user.surname'], attr: 'task_recipients[0].user.surname'}
        fromUserNameColumn = { header: tls['mno_enterprise.templates.components.mnoe-tasks.tasks.column_label.user.name'], attr: 'owner.user.name'}
        fromUserSurnameColumn = { header: tls['mno_enterprise.templates.components.mnoe-tasks.tasks.column_label.user.surname'], attr: 'owner.user.surname'}
        titleColumn = { header: tls['mno_enterprise.templates.components.mnoe-tasks.tasks.column_label.title'], attr: 'title', class: 'ellipsis' }
        messageColumn = { header: tls['mno_enterprise.templates.components.mnoe-tasks.tasks.column_label.message'], attr: 'message', class: 'ellipsis' }
        receivedAtColumn = { header: tls['mno_enterprise.templates.components.mnoe-tasks.tasks.column_label.received'], attr: 'send_at', filter: expandingDateFormat }
        sentAtColumn = { header: tls['mno_enterprise.templates.components.mnoe-tasks.tasks.column_label.sent'], attr: 'send_at', filter: expandingDateFormat }
        readAtColumn = { header: tls['mno_enterprise.templates.components.mnoe-tasks.tasks.column_label.read'], attr: 'task_recipients[0].read_at', filter: expandingDateFormat }
        updatedAtColumn = { header: tls['mno_enterprise.templates.components.mnoe-tasks.tasks.column_label.updated_at'], attr: 'updated_at', filter: expandingDateFormat }
        dueDateAtColumn = { header: tls['mno_enterprise.templates.components.mnoe-tasks.tasks.column_label.due_date'], attr: 'due_date', filter: simpleDateFormat }
        doneColumn = { header: tls['mno_enterprise.templates.components.mnoe-tasks.tasks.column_label.done'], attr: 'status', render: taskDoneCustomField, stopPropagation: true }

        ctrl.mnoSortableTableFields =  switch ctrl.selectedMenu.name
          when 'inbox'
            [fromUserNameColumn, fromUserSurnameColumn, titleColumn, messageColumn, receivedAtColumn, dueDateAtColumn, doneColumn]
          when 'sent'
            [toUserNameColumn, toUserSurnameColumn, titleColumn, messageColumn, sentAtColumn, readAtColumn, dueDateAtColumn, doneColumn]
          when 'draft'
            [toUserNameColumn, toUserSurnameColumn, titleColumn, messageColumn, updatedAtColumn, dueDateAtColumn]
      )

    # Formats dates yesterday & beyond differently from today
    expandingDateFormat = (value)->
      dateFormat = if moment.utc(value) < moment().startOf('day') then 'MMMM d' else 'h:mma'
      $filter('date')(value, dateFormat)

    # A format used across multiple tasks columns
    simpleDateFormat = (value)->
      $filter('date')(value, 'MMMM d')

    # Callback for building a custom "done" checkbox field in the mnoSortableTable component.
    taskDoneCustomField = (rowItem)->
      # If a :completed_at timestamp exist, initialise frontend switch model for checkbox.
      rowItem.markedDone = rowItem.completed_at?
      switch ctrl.selectedMenu.name
        when 'inbox'
          htmlTemplate = """
            <input type="checkbox" class="toggle-task-done" ng-if="rowItem.due_date" ng-model="rowItem.markedDone" ng-change="markDone(rowItem)">
            <span ng-if="!rowItem.due_date">-</span>
          """
        when 'sent'
          label = if rowItem.due_date
            if rowItem.markedDone then 'completed' else 'open'
          else
            '-'
          htmlTemplate = "<span>#{label}</span>"
      {
        scope:
          markDone: (task) ->
            updateTaskStatus(task, task.markedDone)
        template: htmlTemplate
      }

    ctrl
})
