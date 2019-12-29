import Behavior, { ForBehavior } from "../lib/Behaviors"

import store from "../store"

@ForBehavior("bulk-action-visibility")
export default class BulkActionVisibilityBehavior extends Behavior<{}> {
  protected unsubscribe: any

  OnConnect = () => {
    this.unsubscribe = store.subscribe(this.subscriber)
  }

  OnDisconnect = () => {
    store.unsubscribe(this.unsubscribe)
  }

  protected show = () => {
    this.element.classList.remove("hidden")
  }

  protected hide = () => {
    this.element.classList.add("hidden")
  }

  protected subscriber = ({ selection }) => {
    if (selection.length > 0) this.show()
    else this.hide()
  }
}
