import Behavior, { OnEvent, ForBehavior } from "../lib/Behaviors"

import { operations } from "../store/modals"
import store from "../store"

interface Args {
  modal: string
  actionUrl: string
  autocompleteUrl: string
}

@ForBehavior("display-modal")
export default class DisplayModalBehavior extends Behavior<Args> {
  @OnEvent("click")
  click(event: MouseEvent) {
    event.preventDefault()

    store.dispatch(
      operations.show(this.args.modal, {
        url: this.args.actionUrl,
        autocompleteUrl: this.args.autocompleteUrl
      })
    )
  }
}
