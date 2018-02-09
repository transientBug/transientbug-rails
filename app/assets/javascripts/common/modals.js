// Handles dynamically creating and dismissing modals which are stored in
// ejs templates. The templates are automatically compiled by the Rails asset
// pipeline and placed into the global JST object
class AutomaticallyWiredModals {
  get _modalTriggers() { return $("[data-behavior~=neomodal]") }

  handleModalTriggerClick(event) {
    const dataset = event.target.dataset

    const storageTarget = document.getElementById(dataset.storage)

    const templateData = {
      modal: _.omit(dataset, "behavior", "template", "storage"),
      model: Object.assign({}, storageTarget.dataset)
    }

    const template = JST[dataset.template]

    if(!template)
      throw new Error(`Missing modal template for ${ dataset.template }`)

    const renderedModal = template(templateData)

    const modal = $(renderedModal)
    $("body").append(modal)

    modal.modal({
      onHidden: (el) => {
        modal.remove()
      }
    }).modal("show")
  }

  // Called on turbolinks:load events, should wire up all the event handlers
  connect() {
    this._modalTriggers.on("click", this.handleModalTriggerClick.bind(this))
  }

  // Called on turbolinks:visit events, should clear out any existing
  // references and try to cleanup so that little or no memory is leaked.
  disconnect() {
    this._modalTriggers.off("click", this.handleModalTriggerClick.bind(this))
  }
}

App.registerDOMWire(AutomaticallyWiredModals)
