// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//
// To reference this file, add <%= javascript_pack_tag 'public' %> to the appropriate
// layout file, like app/views/layouts/application.html.erb
import renderComponents from "../lib/renderComponents";

import Navbar from "../components/Navbar";

document.addEventListener("turbolinks:load", () => {
  renderComponents({
    '[data-behavior~="navbar-search"]': Navbar
  });
});
