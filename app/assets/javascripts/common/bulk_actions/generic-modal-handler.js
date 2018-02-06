class BulkActionsGenericModalHandler {
  static buildHandler(method) {
    const handler = (triggerData, modelData) => {
      const handlerInstance = new this(triggerData, modelData)
      handlerInstance.method = method
      return handlerInstance.handle()
    }

    return handler
  }

  constructor(triggerData, modelData) {
    this.triggerData = triggerData
    this.modelData = modelData

    this.buildModal()
  }

  get template() { return JST[this.triggerData.template] }

  buildModal() {
    const templateData = {
      action: _.omit(this.triggerData, "behavior", "group", "template"),
      models: this.modelData
    }

    const renderedModal = this.template(templateData)

    this.modal = $(renderedModal)
    $("body").append(this.modal)
  }

  handle() {
    this.modal.modal({
      onHidden: this.onHidden.bind(this),
      onApprove: this.onApprove.bind(this)
    }).modal("show")
  }

  onHidden(el) {
    this.modal.remove()
  }

  buildPayload() {
    const payload = {
      bulk: {
        action: this.triggerData.behavior,
        ids: this.modelData.map((model) => model.id)
      }
    }

    return payload
  }

  async onApprove(el) {
    const response = await App.buildRequest({
      url: this.triggerData.url,
      method: this.method,
      payload: this.buildPayload()
    })

    if(response.ok)
      location.reload(true)
  }
}


const deleteHandler = BulkActionsGenericModalHandler.buildHandler("DELETE")

BulkActions.registerHandlerFor("delete-all", deleteHandler)
BulkActions.registerHandlerFor("revoke-all", deleteHandler)


const postHandler = BulkActionsGenericModalHandler.buildHandler("POST")

BulkActions.registerHandlerFor("recache-all", postHandler)
