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
}

document.addEventListener("turbolinks:load", () => {
  App.init()
})
