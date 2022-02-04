import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "menu" ]

  open() {
    let menuController = this.application.getControllerForElementAndIdentifier(
      this.menuTarget,
      "menu"
    )

    menuController.toggle()
  }
}
