window.App || (window.App = {})

App.init = () => {
  $.fn.api.settings.api = {
    "autocomplete image tags": "/images/tags/autocomplete.json?q={query}",
    "search images": "/images/search.json?q={query}",
    "autocomplete bookmark tags": "/bookmarks/tags/autocomplete.json?q={query}",
    "search bookmarks": "/bookmarks/search.json?q={query}"
  }

  $.fn.api.settings.cache = false
  $.fn.api.settings.debug = true
  $.fn.api.settings.verbose = true

  this.cable || (this.cable = ActionCable.createConsumer())

  $(".message .close").on("click", () => {
    $(this).closest(".message").transition("fade")
  })

  $("[data-behavior~=open-sidebar]").on("click", () => {
    $("#mobile-sidebar")
      .sidebar('setting', 'transition', 'overlay')
      .sidebar("toggle")
  })

  // Setup searching for things. can probably redo this into a bit more dynamic
  // through data attributes
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

  // Lets handle dynamically creating and dismissing modals which are stored in
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
}

document.addEventListener("turbolinks:load", () => {
  App.init()
})
