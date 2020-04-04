import Behavior, { ZobBehavior } from "../lib/Zob"

@ZobBehavior("flash")
export default class FlashBehavior extends Behavior {
  close = () => this.element.classList.add("hidden")
}
