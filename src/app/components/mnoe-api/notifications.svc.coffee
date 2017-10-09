# Service for managing the users.
angular.module 'mnoEnterpriseAngular'
  .service 'MnoeNotifications', ($q, $translate, MnoeFullApiSvc, MnoeOrganizations) ->

    @get = (organizationId)->
      deferred = $q.defer()
      MnoeFullApiSvc
        .one('organizations', organizationId)
        .getList('notifications').then((response) ->
          promises = _.map(response.data.plain(), (notification)->
            NotificationFormatter[notification.notification_type](notification)
          )
          $q.all(promises).then(deferred.resolve)
      )
      deferred.promise

    @notified = (params)->
      MnoeOrganizations.get().then(->
        MnoeFullApiSvc
          .one('organizations', MnoeOrganizations.getSelectedId())
          .all('notifications')
          .doPOST(params, '/notified')
      )

    formatDate = (date)->
      moment(date).format('LL')

    isToday = (date)->
      moment(date).isSame(moment(), 'd')

    NotificationFormatter = {}

    NotificationFormatter.reminder = (notification) ->
      task = notification.task
      deferred = $q.defer()
      $translate([
          'mno_enterprise.templates.components.notifications.reminder.title',
          'mno_enterprise.templates.components.notifications.reminder.message.title',
          'mno_enterprise.templates.components.notifications.reminder.message.from',
          'mno_enterprise.templates.components.notifications.reminder.message.due',
          'mno_enterprise.templates.components.notifications.reminder.message.details'
        ],
        {
          user_name: task.owner.user.name
          user_surname: task.owner.user.surname,
          due_date: formatDate(task.due_date),
          task_title: task.title
        }
      ).then((tls) ->
        message = [
          tls['mno_enterprise.templates.components.notifications.reminder.message.title'],
          tls['mno_enterprise.templates.components.notifications.reminder.message.from'],
          tls['mno_enterprise.templates.components.notifications.reminder.message.due'],
          tls['mno_enterprise.templates.components.notifications.reminder.message.details']
        ].join('</br>')
        deferred.resolve({
          object_id: notification.object_id,
          object_type: notification.object_type,
          notification_type: notification.notification_type,
          method: 'info',
          title: tls['mno_enterprise.templates.components.notifications.reminder.title'],
          message: message,
        })
      )
      deferred.promise

    NotificationFormatter.due = (notification) ->
      task = notification.task
      deferred = $q.defer()
      $translate([
          'mno_enterprise.templates.components.notifications.due.title',
          'mno_enterprise.templates.components.notifications.due.title_today',
          'mno_enterprise.templates.components.notifications.due.message.title',
          'mno_enterprise.templates.components.notifications.due.message.from',
          'mno_enterprise.templates.components.notifications.due.message.details'
        ],
        {
          user_name: task.owner.user.name
          user_surname: task.owner.user.surname,
          due_date: formatDate(task.due_date),
          task_title: task.title
        }
      ).then((tls) ->
        message = [
          tls['mno_enterprise.templates.components.notifications.due.message.title'],
          tls['mno_enterprise.templates.components.notifications.due.message.from'],
          tls['mno_enterprise.templates.components.notifications.due.message.details']
        ].join('</br>')
        title = if isToday(task.due_date)
          tls['mno_enterprise.templates.components.notifications.due.title_today']
        else
          tls['mno_enterprise.templates.components.notifications.due.title']
        deferred.resolve({
          object_id: notification.object_id,
          object_type: notification.object_type,
          notification_type: notification.notification_type,
          method: 'warning',
          title: title,
          message: message,
        })
      )
      deferred.promise

    NotificationFormatter.completed = (notification) ->
      task = notification.task
      recipient = task.task_recipients[0]
      deferred = $q.defer()
      $translate([
          'mno_enterprise.templates.components.notifications.completed.title',
          'mno_enterprise.templates.components.notifications.completed.message.has_completed',
          'mno_enterprise.templates.components.notifications.completed.message.details'
        ],
        {
          user_name: recipient.user.name
          user_surname: recipient.user.surname,
          task_title: task.title
        }
      ).then((tls) ->
        message = [
          tls['mno_enterprise.templates.components.notifications.completed.message.has_completed'],
          tls['mno_enterprise.templates.components.notifications.completed.message.details']
        ].join('</br>')

        deferred.resolve({
          object_id: notification.object_id,
          object_type: notification.object_type,
          notification_type: notification.notification_type,
          method: 'info',
          title: tls['mno_enterprise.templates.components.notifications.completed.title'],
          message: message,
        })
      )
      deferred.promise

    return @
