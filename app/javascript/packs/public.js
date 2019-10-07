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

import "channels"

import "../styles/public"

Rails.start()
Turbolinks.start()
ActiveStorage.start()

// Support component names relative to this directory:
const componentRequireContext = require.context("components", true)
ReactRailsUJS.useContext(componentRequireContext)
// ReactRailsUJS doesn't seem to pick up on Turbolinks like it should
// I wonder if its because Turbolinks.start needs to be called before
// importing ReactRailsUJS?
ReactRailsUJS.detectEvents()

// TODO: make better. Should App be moved away from?
// Do I need it for anything besides a place to put the store?
if (!window.App) window.App = {}
