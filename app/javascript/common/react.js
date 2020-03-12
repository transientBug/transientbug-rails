import React from "react"

import ReactRailsUJS from "react_ujs"

import { Provider } from "react-redux"

import store from "../store/store"

// Support component names relative to this directory:
const componentRequireContext = require.context("components", true)
// ReactRailsUJS.useContext(componentRequireContext)
// Copy pasta from the react-rails ujs source to avoid CSP issues with eval
ReactRailsUJS.getConstructor = className => {
  const parts = className.split(".")
  const filename = parts.shift()
  const keys = parts

  // Load the module:
  let Component = componentRequireContext("./" + filename)

  // Then access each key:
  keys.forEach(function(k) {
    Component = Component[k]
  })

  // support `export default`
  if (Component.__esModule) Component = Component["default"]

  const StoreWrapper = (...args) => (
    <Provider store={store}>
      <Component {...args} />
    </Provider>
  )

  return StoreWrapper
}

// ReactRailsUJS doesn't seem to pick up on Turbolinks like it should
// I wonder if its because Turbolinks.start needs to be called before
// importing ReactRailsUJS?
ReactRailsUJS.detectEvents()
