import Behavior, { OnEvent, ForBehavior } from "../lib/Behaviors"

import store from "../store/store"
import { actions } from "../store/slices/modals"

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
      actions.open({
        name: this.args.modal,
        url: this.args.actionUrl,
        autocompleteUrl: this.args.autocompleteUrl
      })
    )
  }
}
