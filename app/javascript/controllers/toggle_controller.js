import { Controller } from "@hotwired/stimulus"

// https://dev.to/jacobdaddario/hey-style-pop-ups-using-turbo-14p7

export default class extends Controller {
  static targets = [ "toggled" ]
  static classes = [ "toggle" ]

  toggle(event) {
    event.preventDefault()
    if (event.target) document.activeElement.blur()

    this.toggledTargets.forEach((toggled) => {
      toggled.classList.toggle(this.toggleClass)
    })
  }
}
