document.addEventListener("turbolinks:load", () => {
  if (!($(".invitations").length > 0)) {
    return
  }

  $("[data-behavior~=autocomplete-tags]").dropdown({
    apiSettings: {
      cache: false,
      action: "autocomplete image tags"
    },
    fields: {
      name: "title",
      value: "title"
    }
  })

  $("[data-behavior~=delete-modal]").on("click", (event) => {
    let template = JST["admin/templates/invitations/delete"]

    let dataset = event.target.dataset

    let renderedModal = template({
      url: dataset.url,
      title: dataset.title,
      code: dataset.code
    })

    let modal = $(renderedModal)
    $('body').append(modal)

    modal.modal({
      onHidden: (el) => {
        modal.remove()
      }
    }).modal("show")
  })
})
