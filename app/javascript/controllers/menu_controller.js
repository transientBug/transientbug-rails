import { Controller } from "stimulus"

export default class extends Controller {
  static classes = [ "hidden" ]

  toggle() {
    this.element.classList.toggle(this.hiddenClass)
  }
}
