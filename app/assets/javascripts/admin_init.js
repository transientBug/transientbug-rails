window.App || (window.App = {})

App.init = () => {
  $.fn.api.settings.api = { }

  $.fn.api.settings.cache = false
  $.fn.api.settings.debug = true
  $.fn.api.settings.verbose = true

  this.cable || (this.cable = ActionCable.createConsumer())

  $(".message .close").on("click", () => {
    $(this).closest(".message").transition("fade")
  })

  $(".sidebar.icon").on("click", () => {
    $('.ui.sidebar')
      .sidebar('toggle')
  })

  $("[data-behavior~=modal]").on("click", (event) => {
    let dataset = event.target.dataset

    let renderedModal = JST[dataset.template](dataset)

    let modal = $(renderedModal)
    $('body').append(modal)

    modal.modal({
      onHidden: (el) => {
        modal.remove()
      }
    }).modal("show")
  })

  $("[data-behavior~=select-all]").on("change", (event) => {
    $("[data-behavior~=select-all]").prop("checked", event.target.checked)
  })
}

document.addEventListener("turbolinks:load", () => {
  App.init()
})
