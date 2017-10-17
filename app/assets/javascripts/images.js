$(".message .close")
  .on("click", function() {
    $(this)
      .closest(".message")
      .transition("fade")
  })

$("#tags-input").dropdown(
  {
    apiSettings: {
      action: "search tags",
      onResponse: function(apiResponse) {
        var response = {
          results: []
        }

        $.each(apiResponse["results"], function(index, hash) {
          response.results.push({
            name: hash.name,
            text: hash.name,
            value: hash.name
          })
        })

        return response
      }
    }
  }
)
