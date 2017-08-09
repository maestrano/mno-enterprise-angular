angular.module 'mnoEnterpriseAngular'
  .service 'Notifications', ($log, toastr, MnoeNotifications) ->

    NOTIFICATION_TYPE_MAPPING = {
      reminder: 'info',
      due_date: 'warning',
      status_change: 'info',
    }

    @init = () ->
      MnoeNotifications.get().then(
        (response)->
          notifications = response.data.plain()
          for notification in notifications
            notification_type = notification.notification_type
            method = NOTIFICATION_TYPE_MAPPING[notification_type]
            message = notification.message.split("\n").join("</br>")
            title = notification.title
            onHidden = ->
              params = {object_id: notification.object_id, object_type: notification.object_type, notification_type: notification_type}
              MnoeNotifications.notified(params)
            toastr[method](message,title, {
              closeButton: true,
              autoDismiss: false,
              timeOut: null,
              tapToDismiss: true,
              extendedTimeOut: 1000000,
              onHidden: onHidden,
              allowHtml: true

            })
        (errors)->
          $log.error(errors)
      )

    return @
