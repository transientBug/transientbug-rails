App.registerInitializer("semantic-ui api", () => {
  $.fn.api.settings.api = {
    "autocomplete image tags": "/images/tags/autocomplete.json?q={query}",
    "search images": "/images/search.json?q={query}",
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
})
