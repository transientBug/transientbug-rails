import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["removable"]

  remove(event) {
    event.preventDefault()
    this.removableTargets.forEach(target => target.remove())
  }

  removeFromOutside(event) {
    if (this.element.contains(event.target)) return
    this.remove(event)
  }
}
