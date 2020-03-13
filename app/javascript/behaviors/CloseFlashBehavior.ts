import Behavior, { OnEvent, ForBehavior } from "../lib/Behaviors"

@ForBehavior("close-flash")
export default class CloseFlashBehavior extends Behavior {
  @OnEvent("click")
  click(event: MouseEvent) {
    event.preventDefault()

    this.element.closest(".flashes__flash").classList.add("hidden")
  }
}
