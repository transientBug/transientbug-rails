class BulkActions {
  get _selectCheckboxes() { return $("[data-behavior~=select]") }
  get _selectAllCheckbox() { return $("[data-behavior~=select-all]") }
  get _actions() { return $("[data-group~=bulk-edit-action]") }
  get _menus() { return $("[data-group~=bulk-edit-menu]") }

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
    this._menus.toggleClass("hidden", !shouldShow)

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

    BulkActions._handlers[triggerData.behavior](triggerData, modelData)
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
