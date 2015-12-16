angular.module 'mnoEnterpriseAngular'
.service 'themeEditorSvc', ($log, $http) ->
  _self = @

  @saveTheme = (theme) ->
    # Define a boundary, I stole this from IE but you can use any string AFAIK
    boundary = "---------------------------7da24f2e50046"
    body = '--' + boundary + '\r\n'
    # Parameter name is "file" and local filename is "temp.txt"
    body += 'Content-Disposition: form-data; name="theme";' + 'filename="theme.less"\r\n'
    # Add the file's mime-type
    body += 'Content-type: plain/text\r\n\r\n'
    # Add your data
    body += theme + '\r\n'
    body += '--'+ boundary + '--'

    uploadUrl = '/mnoe_theme_previewer'

    $http.post(uploadUrl, body, {
      transformRequest: angular.identity,
      headers: {'Content-Type': "multipart/form-data; boundary="+boundary}
    })
    .success(-> $log.debug('success'))
    .error(-> $log.debug('error'))

  return @
