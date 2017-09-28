angular.module 'mnoEnterpriseAngular'
  .controller 'IndexController', ($scope, $sce, GOOGLE_TAG_CONTAINER_ID, INTERCOM_ID, $window) ->
    'ngInject'

    $scope.google_tag_scripts = $sce.trustAsHtml("""
        <noscript>
            <iframe src=\"\/\/www.googletagmanager.com/ns.html?id=#{GOOGLE_TAG_CONTAINER_ID}\" height=\"0\" width=\"0\" style=\"display:none;visibility:hidden\"></iframe>
        <\/noscript>
        <script>
            (function(w,d,s,l,i){w[l]=w[l]||[];w[l].push(
            {'gtm.start': new Date().getTime(),event:'gtm.js'}
            );var f=d.getElementsByTagName(s)[0],
            j=d.createElement(s),dl=l!='dataLayer'?'&l='+l:'';j.async=true;j.src=
            '//www.googletagmanager.com/gtm.js?id='+i+dl;f.parentNode.insertBefore(j,f);
            })(window,document,'script','dataLayer', '#{GOOGLE_TAG_CONTAINER_ID}');
        <\/script>
    """)if GOOGLE_TAG_CONTAINER_ID?

    # The original intercom script has been slightly modified to invoke l() regardless the state of the
    # window, since the window onload event would not work well with Angularjs.
    $scope.intercom = $sce.trustAsHtml("""
        <script id="IntercomSettingsScriptTag">
          window.intercomSettings = {"widget": {"activator": "#IntercomDefaultWidget"}}
        </script>
        <script>(function(){var w=window;var ic=w.Intercom;if(typeof ic==="function"){ic('reattach_activator');
          ic('update',intercomSettings);}else{var d=document;var i=function(){i.c(arguments)};i.q=[];
          i.c=function(args){i.q.push(args)};w.Intercom=i;function l(){var s=d.createElement('script');
          s.type='text/javascript';s.async=true;s.src='https://widget.intercom.io/widget/#{INTERCOM_ID}';
          var x=d.getElementsByTagName('script')[0];
          x.parentNode.insertBefore(s,x);}l()}})()
        </script>
    """)if INTERCOM_ID?

    return
