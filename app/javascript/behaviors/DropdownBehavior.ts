import Behavior, { ZobBehavior, ValueBinding } from "../lib/Zob"

@ZobBehavior("dropdown")
export default class DropdownBehavior extends Behavior {
  @ValueBinding isOpen = false
  @ValueBinding isClosed = true

  toggleIsOpen = () => (this.isOpen = !(this.isClosed = this.isOpen))
}
