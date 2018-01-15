document.addEventListener("turbolinks:load", () => {
  if (!($(".invitations").length > 0)) {
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
})
