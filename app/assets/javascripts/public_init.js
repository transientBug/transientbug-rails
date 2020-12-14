App.registerInitializer("semantic-ui api", () => {
  $.fn.api.settings.api = {
    "autocomplete bookmark tags": "/bookmarks/tags/autocomplete.json?q={query}",
    "search bookmarks": "/bookmarks/search.json?q={query}"
  }

  $.fn.api.settings.cache = false
  $.fn.api.settings.debug = true
  $.fn.api.settings.verbose = true
  $.fn.api.settings.beforeSend = (settings) => {
    settings.urlData = {
      query: encodeURIComponent(settings.urlData.query)
    }

    return settings
  }

  $.fn.dropdown.settings.selector.input = "> input[data-behaviour~=\"init\"], > select"
})
