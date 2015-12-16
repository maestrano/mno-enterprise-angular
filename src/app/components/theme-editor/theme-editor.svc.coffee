angular.module 'mnoEnterpriseAngular'
.service 'themeEditorSvc', ($log, $http) ->
  _self = @

  @saveTheme = (theme) ->
    uploadUrl = '/mnoe/jpi/v1/admin/theme/save'

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

    $http.post(uploadUrl, body, {
      transformRequest: angular.identity,
      headers: {'Content-Type': "multipart/form-data; boundary="+boundary}
    })
    .success(-> $log.debug('success'))
    .error(-> $log.debug('error'))

  @saveLogo = (file) ->
    uploadUrl = '/mnoe/jpi/v1/admin/theme/logo'

    opts = { transformRequest: angular.identity, headers: {'Content-Type': undefined} }

    data = new FormData()
    data.append('logo', file)

    $http.put(uploadUrl, data, opts)

  return @
