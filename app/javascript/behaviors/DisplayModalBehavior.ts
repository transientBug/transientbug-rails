import Behavior, { ZobBehavior } from "../lib/Zob"

@ZobBehavior("display-modal")
export default class DisplayModalBehavior extends Behavior<{ modal: string }> {
  open = (event: Event) => {
    event.stopPropagation()
    event.preventDefault()

    // TODO: Should/could this make use of the modal elements behavior instead of calling like this?
    // @ts-ignore
    document.getElementById(this.args.modal).showModal()
  }
}
