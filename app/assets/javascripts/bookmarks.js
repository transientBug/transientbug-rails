document.addEventListener("turbolinks:load", () => {
  if (!($(".bookmarks").length > 0)) {
    return
  }

  $("[data-behavior~=autocomplete-tags]").dropdown({
    apiSettings: {
      cache: false,
      action: "autocomplete bookmark tags"
    },
    fields: {
      name: "label",
      value: "label"
    }
  })

  $("[data-behavior~=tag-popup]").popup({
    inline: true
  })
})
