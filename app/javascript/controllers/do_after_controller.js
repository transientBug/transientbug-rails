import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    seconds: Number
  }

  connect() {
    setTimeout(() => {
      this.dispatch("trigger")
    }, this.secondsValue * 1000)
  }
}
