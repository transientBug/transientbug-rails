import { Zob } from "../lib/Zob"

const behaviorsRequireContext = require.context("../behaviors", true, /\.ts/)
const zob = new Zob(behaviorsRequireContext)

document.addEventListener("turbolinks:load", () => {
  zob.Setup()
})

document.addEventListener("turbolinks:before-render", () => {
  zob.Teardown()
})
