import Behavior, { ForBehavior, OnEvent } from "../lib/Behaviors"

import store, { RootState } from "../store/store"
import { actions } from "../store/slices/selections"

@ForBehavior("bulk-action-select-all")
export default class BulkActionSelectAllBehavior extends Behavior<{}> {
  protected unsubscribe: any
  protected checkbox: HTMLInputElement

  OnConnect = () => {
    this.unsubscribe = store.subscribe(this.subscriber)
    this.checkbox = this.element.querySelector(`input[type=checkbox]`)
  }

  OnDisconnect = () => {
    this.unsubscribe()
  }

  @OnEvent("click")
  click(_event) {
    const { records } = store.getState() as RootState

    if (this.checkbox.checked)
      store.dispatch(
        actions.addAll(Object.keys(records.objects).map(i => parseInt(i)))
      )
    else store.dispatch(actions.clear())
  }

  protected subscriber = () => {
    const { selection } = store.getState() as RootState

    this.checkbox.checked = selection.selection.length > 0
  }
}
