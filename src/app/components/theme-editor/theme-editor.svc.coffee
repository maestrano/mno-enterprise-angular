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

  @getTheme = ->
    $log.debug('Loading custom theme')
    $http.get('styles/theme.less').then((response) ->
      data  = response.data
      return getLessVars(data)
    )

  getLessVars = (lessStr)->
    lines = lessStr.split('\n')
    lessVars = {}
    for line in lines
      if line.indexOf('@') is 0
        i = line.indexOf(':')
        keyVar = line.slice(0,i)
        value = line.trim().slice(i+1, -1).trim()
        lessVars[keyVar] = value

    return lessVars

  return @
