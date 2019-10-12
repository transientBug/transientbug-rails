document.addEventListener("turbolinks:load", () => {
  // Dismiss messages when the X is clicked
  $(".message .close").on("click", (event) => {
    $(event.target).closest(".message").transition("fade")
  })

  // Toggle the sidebar open and closed
  $(".sidebar.icon").parent().on("click", () => $(".ui.sidebar").sidebar("toggle"))

  tagDropdown(
    "[data-behavior~=autocomplete-image-tags]",
    "autocomplete image tags", {
      name: "title",
      value: "title"
    }
  )

  tagDropdown(
    "[data-behavior~=autocomplete-bookmark-tags]",
    "autocomplete bookmark tags", {
      name: "label",
      value: "label"
    }
  )

  // Setup searching for things. This could probably be simplified with data attributes.
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

  $("[data-behavior~=dropdown]").dropdown()
})

const tagDropdown = (selector, action, fields) => {
  // This is a massive hack to get around FireFox caching hidden input field
  // data because its all awful
  const tagInput = $(`${ selector } > input[data-behaviour~=\"init\"]`)
  if(tagInput.length != 0) {
    const rawTags = tagInput.val()
    const tags = rawTags.split(",").filter((t) => !(_.isEmpty(t) || _.isNil(t))).map((t) => ({ name: t, value: t, label: t, title: t, selected: true }))

    $(selector).dropdown({
      apiSettings: {
        cache: false,
        action
      },
      fields,
      values: tags
    })
  }
}
