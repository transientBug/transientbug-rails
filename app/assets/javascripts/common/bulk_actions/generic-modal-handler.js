class BulkActionsGenericModalHandler {
  get loader() { return $("#page-loader") }
  constructor(method) {
    this._method = method
  }

  async onApprove({ triggerData, modelData, button }) {
    const payload = {
      bulk: {
        action: triggerData.behavior,
        ids: modelData.map((model) => model.id)
      }
    }

    const response = await App.buildRequest({
      url: triggerData.url,
      method: this._method,
      payload: payload
    })

    if(response.ok)
      location.reload(true)
  }

  setLoader(text) {
    this.loader.addClass("indeterminate text")

    this.loader.innerText = text

    this.loader.parent(".dimmer").dimmer("show")
  }

  onHide(el) {
    this.setLoader("Performing bulk actions ... please wait")
    return true
  }

  onHidden(modal, el) {
    this.loader.removeClass("indeterminate text")
    modal.remove()
  }

  handleBulkActionTrigger({ triggerData, modelData }) {
    const templateData = {
      action: _.omit(triggerData, "behavior", "group", "template"),
      models: modelData
    }

    const curriedHandler = (modal, el) => this.onApprove({ triggerData: triggerData, modelData: modelData, modal: modal, button: el })

    const renderedModal = JST[triggerData.template](templateData)

    const modal = $(renderedModal)
    $("body").append(modal)

    modal.modal({
      onHide: this.onHide.bind(this),
      onHidden: this.onHidden.bind(this, modal),
      onApprove: curriedHandler.bind(this, modal)
    })

    modal.modal("show")

    return modal
  }
}


const deleteHandler = new BulkActionsGenericModalHandler("DELETE")

BulkActions.registerHandlerFor("delete-all", deleteHandler)
BulkActions.registerHandlerFor("revoke-all", deleteHandler)


const postHandler = new BulkActionsGenericModalHandler("POST")

BulkActions.registerHandlerFor("recache-all", postHandler)
