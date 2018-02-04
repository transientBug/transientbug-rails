class BulkActions {
  get _selectCheckboxes() { return $("[data-behavior~=select]") }
  get _selectAllCheckbox() { return $("[data-behavior~=select-all]") }
  get _actions() { return $("[data-group~=bulk-edit-action]") }

  allSelectsChecked() {
    return _.every(this._selectCheckboxes, (value) => $(value).prop("checked"))
  }

  anySelectsChecked() {
    return _.some(this._selectCheckboxes, (value) => $(value).prop("checked"))
  }

  allSelectsUnchecked() {
    return !this.allSelectsChecked()
  }

  toggleBulkActionsVisibility(shouldShow) {
    this._actions.toggleClass("hidden", !shouldShow)

    const sticky = this._actions.parents("[data-behavior~=sticky]")

    if(sticky)
      sticky.sticky("refresh")
  }

  toggleSelectAllChecked(shouldShow) {
    if(shouldShow) {
      this.refreshSelectAll()

      this.toggleBulkActionsVisibility(true)
    } else {
      // If the select all is checked and we're being unchecked, uncheck the
      // select all
      if(this._selectAllCheckbox.prop("checked"))
        this._selectAllCheckbox.prop("checked", false)

      if(this.allSelectsUnchecked())
        this.toggleBulkActionsVisibility(false)
    }
  }

  refreshSelectAll() {
    if(this._selectCheckboxes.length == 0)
      return

    // If all select boxes are checked, check the select all
    this._selectAllCheckbox.prop("checked", this.allSelectsChecked())
  }

  handleSelectAllChanged(event) {
    const target = $(event.target)
    const checked = target.prop("checked")

    this._selectCheckboxes.prop("checked", checked)
    this.toggleBulkActionsVisibility(checked)
  }

  handleSelectCheckboxesChanged(event) {
    const target = $(event.target)

    this.toggleSelectAllChecked(target.prop("checked"))
  }

  handleBulkActionClicked(event) {
    const dataset = event.target.dataset

    const triggerData = Object.assign({}, dataset)
    const modelData = $("[data-behavior~=select]:checked").siblings()
      .toArray()
      .map((element) => Object.assign({}, element.dataset))

    const templateData = {
      action: _.omit(triggerData, "behavior", "group", "template"),
      models: modelData
    }

    const loader = $("#page-loader")
    loader.addClass("indeterminate text")
    loader.innerText = "Performing bulk actions ... please wait"

    const curriedHandler = (modal) => {
      return BulkActions._handlers[triggerData.behavior]({
        triggerData: triggerData,
        modelData: modelData,
        modal: modal
      })
    }

    const renderedModal = JST[triggerData.template](templateData)

    const modal = $(renderedModal)
    $("body").append(modal)

    modal.modal({
      onHide: (el) => {
        loader.parent(".dimmer").dimmer("show")
        return true
      },
      onHidden: (el) => {
        loader.removeClass("indeterminate text")
        modal.remove()
      },
      onApprove: curriedHandler
    }).modal("show")
  }

  static registerHandlerFor(behavior, handler) {
    this.handlers[behavior] = handler
  }

  static get handlers() {
    return this._handlers || (this._handlers = {})
  }

  static set handlers(val) {
    this._handlers = val
  }

  static buildRequest({url, method, payload}) {
    const csrfParam = Rails.csrfParam()
    const csrfToken = Rails.csrfToken()
    // Add rails csrf token
    payload[ csrfParam ] = csrfToken

    return fetch(url, {
      method: method,
      headers: new Headers({
        "Content-Type": "application/json",
        "Accept": "application/json",
        "X-CSRF-Token": csrfToken,
        "X-Requested-With": "XMLHttpRequest"
      }),
      credentials: "same-origin",
      body: JSON.stringify(payload)
    })
  }

  // Let's setup our handlers, make sure we toggle the bulk actions if any
  // checkboxes are selected and teardown listeners when we're closing the page
  connect() {
    this.refreshSelectAll()
    this.toggleBulkActionsVisibility(this.anySelectsChecked())

    this._selectAllCheckbox.on("change", this.handleSelectAllChanged.bind(this))
    this._selectCheckboxes.on("change", this.handleSelectCheckboxesChanged.bind(this))
    this._actions.on("click", this.handleBulkActionClicked.bind(this))
  }

  disconnect() {
    this._selectAllCheckbox.off("change", this.handleSelectAllChanged.bind(this))
    this._selectCheckboxes.off("change", this.handleSelectCheckboxesChanged.bind(this))
    this._actions.off("click", this.handleBulkActionClicked.bind(this))
  }
}

App.registerDOMWire(BulkActions)

async function deleteAllHandler({triggerData, modelData, modal}) {
  const payload = {
    bulk: {
      action: triggerData.behavior,
      ids: modelData.map((model) => model.id)
    }
  }

  const response = await BulkActions.buildRequest({
    url: triggerData.url,
    method: "DELETE",
    payload: payload
  })

  if(response.ok)
    location.reload(true)
}

BulkActions.registerHandlerFor("delete-all", deleteAllHandler)
BulkActions.registerHandlerFor("revoke-all", deleteAllHandler)
