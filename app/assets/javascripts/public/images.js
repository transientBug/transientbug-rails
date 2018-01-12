document.addEventListener("turbolinks:load", () => {
  if (!($(".images").length > 0)) {
    return
  }

  $("[data-behavior~=autocomplete-tags]").dropdown({
    apiSettings: {
      cache: false,
      action: "autocomplete image tags"
    },
    fields: {
      name: "title",
      value: "title"
    }
  })

  $("[data-behavior~=tag-popup]").popup({
    inline: true
  })
})
