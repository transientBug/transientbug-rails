window.App || (window.App = {})

App.init = () => {
  $.fn.api.settings.api = { }

  $.fn.api.settings.cache = false
  $.fn.api.settings.debug = true
  $.fn.api.settings.verbose = true

  this.cable || (this.cable = ActionCable.createConsumer())

  // Dismiss messages when the X is clicked
  $(".message .close").on("click", () => {
    $(this).closest(".message").transition("fade")
  })

  // Toggle the sidebar open and closed
  $(".sidebar.icon").on("click", () => {
    $('.ui.sidebar')
      .sidebar('toggle')
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

  // And now for select all and the bulk edit toolbar things
  //
  // TODO:
  //   Could this all be done with like $("[data-behavior~=select]:checked").size()
  //   checks?
  const toggleBulkEditToolbar = (shouldShow) => {
    $("[data-behavior~=bulk-edit-menu]").toggleClass("hidden", !shouldShow)
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
