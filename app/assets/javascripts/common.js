document.addEventListener("turbolinks:load", () => {
  // Dismiss messages when the X is clicked
  $(".message .close").on("click", (event) => {
    $(event.target).closest(".message").transition("fade")
  })

  $(".ui.accordion").accordion()

  // Toggle the sidebar open and closed
  $(".sidebar.icon").parent().on("click", () => $(".ui.sidebar").sidebar("toggle"))

  // Handle making the side menus sticky
  $("[data-behavior~=sticky]").each((idx, element) => {
    if($(element.dataset.context).length < 1)
      return

    let stickySettings = Object.assign({}, element.dataset)
    if(stickySettings.offset)
      stickySettings.offset = parseInt(stickySettings.offset)

    $(element).sticky(stickySettings)
  })

  // Setup autocomplete forms for image and bookmark tags. This could probably
  // be simplified with data attributes.
  $("[data-behavior~=autocomplete-image-tags]").dropdown({
    apiSettings: {
      cache: false,
      action: "autocomplete image tags"
    },
    fields: {
      name: "title",
      value: "title"
    }
  })

  // TODO: Need to refactor some bits of the image stuff in another PR
  //tagDropdown("[data-behavior~=autocomplete-image-tags]", "autocomplete image tags")
  tagDropdown("[data-behavior~=autocomplete-bookmark-tags]", "autocomplete bookmark tags")

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

  $("[data-behavior~=tag-popup]").popup({
    inline: true
  })

  $("[data-behavior~=dropdown]").dropdown()
})

const tagDropdown = (selector, action) => {
  // This is a massive hack to get around FireFox caching hidden input field
  // data because its all awful
  const tagInput = $(`${ selector } > input[data-behaviour~=\"init\"]`)
  if(tagInput.length > 0) {
    const rawTags = tagInput.val()
    const tags = rawTags.split(",").map((t) => ({ name: t, value: t, label: t, selected: true }))

    $(selector).dropdown({
      apiSettings: {
        cache: false,
        action
      },
      fields: {
        name: "label",
        value: "label"
      },
      values: tags
    })
  }
}
