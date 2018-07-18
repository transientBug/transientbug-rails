/* eslint no-console:0 */
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//
// To reference this file, add <%= javascript_pack_tag 'application' %> to the appropriate
// layout file, like app/views/layouts/application.html.erb
import * as Mousetrap from "mousetrap"

console.log("Hello World from Webpacker")

document.addEventListener("turbolinks:load", () => {
  const dropdown = document.querySelector(".tb.search > .dropdown")

  const isVisible = () => !dropdown.classList.contains("hidden")

  Mousetrap.bind(["/"], () => {
    dropdown.classList.remove("hidden")
    return false
  })

  Mousetrap.bind(["esc"], () => {
    dropdown.classList.add("hidden")
    return false
  })

  Mousetrap.bind(["?"], () => {
    console.log("Is dropdown visible?", isVisible())

    if (!isVisible())
      return true

    console.log("Help dialogue toggle")
    return false
  })
})
