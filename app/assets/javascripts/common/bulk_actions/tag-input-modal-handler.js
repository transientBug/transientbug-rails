class BulkActionTagInputModalHandler extends BulkActionsGenericModalHandler {
  static buildHandler() { return super.buildHandler("PATCH") }

  get tagsInput() { return this.modal.find("[data-behavior~=autocomplete-bookmark-tags]") }

  constructor(triggerData, modelData) {
    super(triggerData, modelData)

    this.tagsInput.dropdown({
      apiSettings: {
        cache: false,
        action: "autocomplete bookmark tags"
      },
      fields: {
        name: "label",
        value: "label"
      }
    })
  }

  buildPayload() {
    const payload = {
      bulk: {
        action: this.triggerData.behavior,
        ids: this.modelData.map((model) => model.id),
        tags: this.tagsInput.val()
      }
    }

    return payload
  }
}

const tagInputModalHandler = BulkActionTagInputModalHandler.buildHandler()
BulkActions.registerHandlerFor("tag-all", tagInputModalHandler)
