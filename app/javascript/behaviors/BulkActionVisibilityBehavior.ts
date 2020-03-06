import Behavior, { ForBehavior } from "../lib/Behaviors"

import store, { RootState } from "../store/store"

@ForBehavior("bulk-action-visibility")
export default class BulkActionVisibilityBehavior extends Behavior<{}> {
  protected unsubscribe: any

  OnConnect = () => {
    this.unsubscribe = store.subscribe(this.subscriber)
  }

  OnDisconnect = () => {
    this.unsubscribe()
  }

  protected subscriber = () => {
    const { selection } = store.getState() as RootState

    if (selection.selection.length > 0) this.element.classList.remove("hidden")
    else this.element.classList.add("hidden")
  }
}
