window.App || (window.App = {})

App.init = () => {
  $.fn.api.settings.api = {
    "search tags": "/images/search.json?t=tags&q={query}",
    "search images": "/images/search.json?t=images&q={query}",
    "search": "/images/search.json?q={query}"
  }

  $.fn.api.settings.cache = false
  $.fn.api.settings.debug = true
  $.fn.api.settings.verbose = true

  $(".message .close").on("click", () => {
    $(this).closest(".message").transition("fade")
  })

  this.cable || (this.cable = ActionCable.createConsumer())
}

document.addEventListener("turbolinks:load", () => {
  App.init()
})
