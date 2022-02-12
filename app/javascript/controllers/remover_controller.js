import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["removable"]

  remove(event) {
    this.removableTargets.forEach(target => target.remove())
  }
}
