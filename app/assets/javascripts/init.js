window.App || (window.App = {})

App.init = () => {
  $.fn.api.settings.api = {
    "autocomplete tags": "/images/tags/autocomplete.json?q={query}",
    "search images": "/images/search.json?q={query}"
  }

  $.fn.api.settings.cache = false
  $.fn.api.settings.debug = true
  $.fn.api.settings.verbose = true

  $(".message .close").on("click", () => {
    $(this).closest(".message").transition("fade")
  })

  this.cable || (this.cable = ActionCable.createConsumer())

  $("[data-behavior~=search-images]").search({
    type: "category",
    minCharacters: 2,
    cache: false,
    searchFields   : [
      "title"
    ],
    apiSettings: {
      cache: false,
      action: "search images"
    },
    fields: {
      url: "view"
    }
  })
}

document.addEventListener("turbolinks:load", () => {
  App.init()
})
