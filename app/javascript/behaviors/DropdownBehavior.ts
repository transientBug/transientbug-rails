import Behavior, { ZobBehavior, ValueBinding } from "../lib/Zob"

@ZobBehavior("dropdown")
export default class DropdownBehavior extends Behavior {
  @ValueBinding isOpen = false

  toggleIsOpen = () => (this.isOpen = !this.isOpen)
}
