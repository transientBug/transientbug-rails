// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//
// To reference this file, add <%= javascript_pack_tag 'public' %> to the appropriate
// layout file, like app/views/layouts/application.html.erb
// import "core-js/stable"
// import "regenerator-runtime/runtime"

import Rails from "@rails/ujs"
import Turbolinks from "turbolinks"
import * as ActiveStorage from "@rails/activestorage"
import ReactRailsUJS from "react_ujs"
import { DataBehaviors } from "../lib/Behaviors"

import "channels"

// For some reason I've got to import the store first before anything gets hooked up, and I'm not sure why ...
import "../store"

import "../styles/public"

/** Turbolinks and inline body script tags with a CSP nonce don't seem to play nice.
 * Probably not recommended to do this but :/ Nothing else it working
 *
 * this is a vanilla version of whats documented here
 * https://github.com/turbolinks/turbolinks/issues/430
 */
document.addEventListener("turbolinks:request-start", event => {
  const xhr = event.data.xhr
  xhr.setRequestHeader("X-Turbolinks-Nonce", Rails.cspNonce())
})

// window.store = store
// store.subscribe(state => console.table(Object.entries(state)))

Rails.start()
Turbolinks.start()
ActiveStorage.start()

// Support component names relative to this directory:
const componentRequireContext = require.context("components", true)
// ReactRailsUJS.useContext(componentRequireContext)
// Copy pasta from the react-rails ujs source to avoid CSP issues with eval
ReactRailsUJS.getConstructor = className => {
  const parts = className.split(".")
  const filename = parts.shift()
  const keys = parts

  // Load the module:
  let component = componentRequireContext("./" + filename)

  // Then access each key:
  keys.forEach(function(k) {
    component = component[k]
  })

  // support `export default`
  if (component.__esModule) component = component["default"]

  return component
}
// ReactRailsUJS doesn't seem to pick up on Turbolinks like it should
// I wonder if its because Turbolinks.start needs to be called before
// importing ReactRailsUJS?
ReactRailsUJS.detectEvents()

const behaviorsRequireContext = require.context("../behaviors", true, /\.ts/)
const dataBehaviors = new DataBehaviors(behaviorsRequireContext)

document.addEventListener("turbolinks:load", () => {
  dataBehaviors.connect()
})

document.addEventListener("turbolinks:before-render", () => {
  dataBehaviors.disconnect()
})
