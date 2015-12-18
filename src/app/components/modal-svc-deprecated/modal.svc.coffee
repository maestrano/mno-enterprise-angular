angular.module 'mnoEnterpriseAngular'
  .factory('ModalSvc', ($log, $modal) ->

    $log.warn('ModalSvc is deprecated. Please use MnoConfirm instead, or directly $uibModal.')

    # --------------------------------------------------------------------
    # The goal of this service is to create a generic modal creator
    # This is a wip
    # --------------------------------------------------------------------
    service = {}

    # --------------------------------------------------------------------
    # Generic Modal class
    # --------------------------------------------------------------------
    class Modal
      # Mandatory options:
      # ------------------
      # templateUrl: url of the template
      #
      # Optional options:
      # -----------------
      # backdrop
      # modalSize
      # modalClass (e.g. inverse)
      # callback: function called after proceed() if successful
      constructor: (@opts) ->
        # TODO: exceptions if opts is not complete

      config: () ->
        self = this
        {
          instance: {
            templateUrl: self.opts.templateUrl
            controller:  self.opts.controller
            backdrop:    self.opts.backdrop       || 'static'
            size:        self.opts.modalSize      || 'lg'
            windowClass: self.opts.modalClass     || 'inverse'
            resolve: {
              $modalInstanceCB: (-> return self.opts.callback)
            }
          }
        }

      # Open the modal
      open: () ->
        self = this
        $modal.open(self.config().instance)

    # --------------------------------------------------------------------
    # Service instanciations
    # --------------------------------------------------------------------
    service.new = (opts = {}) ->
      return new Modal(opts)

    service.newOrgModal = (opts = {}) ->
      opts.templateUrl = 'app/components/modal-svc-deprecated/new-org-modal/new-organization.html'
      opts.controller = 'NewOrgModalCtrl'
      return new Modal(opts)

    return service
  )
