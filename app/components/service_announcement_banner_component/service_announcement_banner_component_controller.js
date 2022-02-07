import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    "id": String,
    "hidden": Boolean
  }

  static classes = ["hidden"]

  get storageKey() {
    return `hidden.service-announcements.${this.idValue}`
  }

  get isHidden() {
    if (this.hiddenValue) return true
    if (localStorage.getItem(this.storageKey)) return true

    return false
  }

  connect() {
    if (this.isHidden) this.hide()
  }

  hide(event) {
    event?.preventDefault()

    this.hiddenValue = true
    localStorage.setItem(this.storageKey, true)
    this.element.classList.add(this.hiddenClass)
  }
}
