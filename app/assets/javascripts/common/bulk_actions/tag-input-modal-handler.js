class BulkActionTagInputModalHandler extends BulkActionsGenericModalHandler {
  handleBulkActionTrigger({ triggerData, modelData }) {
    const modal = super.handleBulkActionTrigger({ triggerData: triggerData, modelData: modelData })

    const tagsInput = modal.find("[data-behavior~=autocomplete-bookmark-tags]")

    tagsInput.dropdown({
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

  async onApprove({ triggerData, modelData, button, modal }) {
    const tagsInput = modal.find("[data-behavior~=autocomplete-bookmark-tags]")

    const payload = {
      bulk: {
        action: triggerData.behavior,
        ids: modelData.map((model) => model.id),
        tags: tagsInput.val()
      }
    }

    const response = await App.buildRequest({
      url: triggerData.url,
      method: "PATCH",
      payload: payload
    })

    if(response.ok)
      location.reload(true)
  }
}

const tagInputModalHandler = new BulkActionTagInputModalHandler()
BulkActions.registerHandlerFor("tag-all", tagInputModalHandler)
