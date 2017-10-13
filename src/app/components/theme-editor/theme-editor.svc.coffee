angular.module 'mnoEnterpriseAngular'
.service 'themeEditorSvc', ($log, $http) ->
  _self = @

  @saveTheme = (theme,opts = {}) ->
    uploadUrl = '/mnoe/jpi/v1/admin/theme/save'

    body = {
      theme: theme,
      publish: !!opts.publish
    }

    $http.post(uploadUrl, angular.toJson(body), {
      transformRequest: angular.identity,
    })

  @saveLogo = (file) ->
    uploadUrl = '/mnoe/jpi/v1/admin/theme/logo'

    opts = { transformRequest: angular.identity, headers: {'Content-Type': undefined} }

    data = new FormData()
    data.append('logo', file)

    $http.put(uploadUrl, data, opts)

  @resetToPublishedTheme = ->
    resetUrl = '/mnoe/jpi/v1/admin/theme/reset'
    $http.post(resetUrl,'')

  @resetToDefaultTheme = ->
    resetUrl = '/mnoe/jpi/v1/admin/theme/reset'
    $http.post(resetUrl,{default: true})

  @getTheme = ->
    $log.debug('Loading custom theme')
    $http.get('styles/theme-previewer.less').then((response) ->
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
