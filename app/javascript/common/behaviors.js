import { DataBehaviors } from "../lib/Behaviors"

const behaviorsRequireContext = require.context("../behaviors", true, /\.ts/)
const dataBehaviors = new DataBehaviors(behaviorsRequireContext)

document.addEventListener("turbolinks:load", () => {
  dataBehaviors.connect()
})

document.addEventListener("turbolinks:before-render", () => {
  dataBehaviors.disconnect()
})
