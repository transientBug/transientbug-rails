window.App || (window.App = {})

$.fn.api.settings.api = {
  "search tags": "/images/search.json?t=tags&q={query}"
}

App.init = () => {
  $(".message .close").on("click", () => {
    $(this).closest(".message").transition("fade")
  })

  this.cable || (this.cable = ActionCable.createConsumer())
}


document.addEventListener("turbolinks:load", () => {
  App.init()
})
