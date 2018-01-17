window.App || (window.App = {})

App.init = () => {
  $.fn.api.settings.api = { }
}

document.addEventListener("turbolinks:load", () => {
  App.init()
})
