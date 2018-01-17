document.addEventListener("turbolinks:load", () => {
  $.fn.api.settings.cache = false
  $.fn.api.settings.debug = true
  $.fn.api.settings.verbose = true

  this.cable || (this.cable = ActionCable.createConsumer())

  // Dismiss messages when the X is clicked
  $(".message .close").on("click", (event) => {
    $(event.target).closest(".message").transition("fade")
  })

  // Toggle the sidebar open and closed
  $(".sidebar.icon").on("click", () => {
    $('.ui.sidebar')
      .sidebar('toggle')
  })

  // Let's handle dynamically creating and dismissing modals which are stored in
  // ejs templates
  $("[data-behavior~=modal]").on("click", (event) => {
    let dataset = event.target.dataset

    let renderedModal = JST[dataset.template](dataset)

    let modal = $(renderedModal)
    $('body').append(modal)

    modal.modal({
      onHidden: (el) => {
        modal.remove()
      }
    }).modal("show")
  })

  // Handle making the side menus sticky
  $("[data-behavior~=sticky]").each((idx, element) => {
    let stickySettings = Object.assign({}, element.dataset)
    if(stickySettings.offset)
      stickySettings.offset = parseInt(stickySettings.offset)

    $(element).sticky(stickySettings)
  })

  // And now for select all and the bulk edit toolbar things. This also will
  // refresh any sticky objects that the toolbars might be a part of
  //
  // TODO:
  //   Could this all be done with like $("[data-behavior~=select]:checked").size()
  //   checks?
  const toggleBulkEditToolbar = (shouldShow) => {
    let bulkEditItems = $("[data-behavior~=bulk-edit-menu]")
    bulkEditItems.toggleClass("hidden", !shouldShow)

    let sticky = bulkEditItems.parents("[data-behavior~=sticky]")

    if(sticky)
      sticky.sticky("refresh")
  }

  let selectCheckboxes = $("[data-behavior~=select]")
  let selectAll = $("[data-behavior~=select-all]")

  // If the select all is clicked or unclicked, update all of the selects
  selectAll.on("change", (event) => {
    let target = $(event.target)
    let checked = target.prop("checked")

    selectCheckboxes.prop("checked", checked)
    toggleBulkEditToolbar(checked)
  })

  selectCheckboxes.on("change", (event) => {
    let target = $(event.target)

    if(target.prop("checked")) {
      // If we're being checked, and all others are checked, check the select all
      let allChecked = _.every(selectCheckboxes, (value, idx, col) => $(value).prop("checked"))

      if(allChecked)
        selectAll.prop("checked", true)

      toggleBulkEditToolbar(true)
    } else {
      // If the select all is checked and we're being unchecked, uncheck the
      // select all
      if(selectAll.prop("checked"))
        selectAll.prop("checked", false)

      let allUnchecked = _.every(selectCheckboxes, (value, idx, col) => !$(value).prop("checked"))

      if(allUnchecked)
        toggleBulkEditToolbar(false)
    }
  })

  // Setup autocomplete forms for image and bookmark tags. This could probably be simplified with data attributes.
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

  $("[data-behavior~=autocomplete-bookmark-tags]").dropdown({
    apiSettings: {
      cache: false,
      action: "autocomplete bookmark tags"
    },
    fields: {
      name: "label",
      value: "label"
    }
  })

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
})
