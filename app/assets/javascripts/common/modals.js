// Handles dynamically creating and dismissing modals which are stored in
// ejs templates. The templates are automatically compiled by the Rails asset
// pipeline and placed into the global JST object
class AutomaticallyWiredModals {
  get _modalTriggers() { return $("[data-behavior~=modal]") }

  handleModalTriggerClick(event) {
    const dataset = event.target.dataset

    const renderedModal = JST[dataset.template](dataset)

    const modal = $(renderedModal)
    $('body').append(modal)

    modal.modal({
      onHidden: (el) => {
        modal.remove()
      }
    }).modal("show")
  }

  constructor() {
    this._modalTriggers.on("click", this.handleModalTriggerClick.bind(this))
  }

  destroy() {
    this._modalTriggers.off("click", this.handleModalTriggerClick.bind(this))
  }
}

App.registerInit(AutomaticallyWiredModals)
