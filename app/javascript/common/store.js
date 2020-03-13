import store from "../store/store"
import { reset } from "../store/slices/resetAction"

document.addEventListener("turbolinks:load", () => {
  store.dispatch(reset(window.__initStore__ || {}))
})

document.addEventListener("turbolinks:request-start", () => {
  store.dispatch(reset({}))
})
