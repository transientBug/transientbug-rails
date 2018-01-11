window.App || (window.App = {})

App.init = () => {
  $.fn.api.settings.api = {
    "autocomplete image tags": "/images/tags/autocomplete.json?q={query}",
    "search images": "/images/search.json?q={query}",
    "autocomplete bookmark tags": "/bookmarks/tags/autocomplete.json?q={query}",
    "search bookmarks": "/bookmarks/search.json?q={query}"
  }

  $.fn.api.settings.cache = false
  $.fn.api.settings.debug = true
  $.fn.api.settings.verbose = true

  this.cable || (this.cable = ActionCable.createConsumer())

  $(".message .close").on("click", () => {
    $(this).closest(".message").transition("fade")
  })

  $("[data-behavior~=open-sidebar]").on("click", () => {
    $("#mobile-sidebar")
      .sidebar('setting', 'transition', 'overlay')
      .sidebar("toggle")
  })

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

  $("[data-behavior~=search-bookmarks]").search({
    type: "category",
    minCharacters: 2,
    cache: false,
    searchFields   : [
      "title"
    ],
    apiSettings: {
      cache: false,
      action: "search bookmarks"
    },
    fields: {
      url: "view"
    }
  })
}

document.addEventListener("turbolinks:load", () => {
  App.init()
})
