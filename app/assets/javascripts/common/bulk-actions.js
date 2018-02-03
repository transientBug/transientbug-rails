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

    const loader = $("#page-loader")
    loader.innerText = "Performing bulk actions ... please wait"

    const modelData = $("[data-behavior~=select]:checked").siblings()
      .toArray()
      .map((element) => Object.assign({}, element.dataset))

    const templateData = {
      action: _.omit(dataset, "behavior", "group", "template"),
      models: modelData
    }

    const renderedModal = JST[dataset.template](templateData)

    const modal = $(renderedModal)
    $("body").append(modal)

    const payload = {
      bulk: {
        action: dataset.behavior,
        ids: modelData.map((model) => model.id)
      }
    }

    // Add rails csrf token
    payload[ Rails.csrfParam() ] = Rails.csrfToken()

    modal.modal({
      onHide: (el) => {
        loader.parent(".dimmer").dimmer("show")
        return true
      },
      onHidden: (el) => {
        modal.remove()
      },
      onApprove: (el) => {
        // TODO: look for a custom handler in like App.bulks.handlers or
        // something, and fallback to a default one like this otherwise?
        // That would allow for DELETE requests and such for custom bulks
        fetch(dataset.url, {
          method: "POST",
          credentials: "same-origin",
          headers: new Headers({
            "Content-Type": "application/json",
            "Accept": "application/json",
            "X-CSRF-Token": Rails.csrfToken(),
            "X-Requested-With": "XMLHttpRequest"
          }),
          body: JSON.stringify(payload)
        }).then((result) => {
          if(result.ok)
            location.reload(true)
        })
      }
    }).modal("show")
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
