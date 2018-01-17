window.App || (window.App = {})

App.init = () => {
  $.fn.api.settings.api = {
    "autocomplete image tags": "/images/tags/autocomplete.json?q={query}",
    "search images": "/images/search.json?q={query}",
    "autocomplete bookmark tags": "/bookmarks/tags/autocomplete.json?q={query}",
    "search bookmarks": "/bookmarks/search.json?q={query}"
  }
}

document.addEventListener("turbolinks:load", () => {
  App.init()
})
