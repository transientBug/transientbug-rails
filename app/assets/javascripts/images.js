document.addEventListener("turbolinks:load", () => {
  if (!($(".images").length > 0)) {
    return
  }

  $("#tags-input").dropdown({
    apiSettings: {
      cache: false,
      action: "search tags",
      onResponse: (apiResponse) => {
        var response = {
          results: []
        }

        $.each(apiResponse["results"], (index, hash) => {
          response.results.push({
            name: hash.name,
            text: hash.name,
            value: hash.name
          })
        })

        return response
      }
    }
  })
})
