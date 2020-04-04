import Behavior, { ZobBehavior, ValueBinding } from "../lib/Zob"

import store from "../store/store"
import { actions } from "../store/slices/selections"

@ZobBehavior("bulk-action-select-all")
export default class BulkActionSelectAllBehavior extends Behavior {
  protected unsubscribe: any
  protected checkbox: HTMLInputElement

  @ValueBinding hasSelection = false

  Setup = () => {
    this.unsubscribe = store.subscribe(this.subscriber)
    this.checkbox = this.element.querySelector(`input[type=checkbox]`)
    this.checkbox.onclick = this.click
  }

  Teardown = () => {
    this.unsubscribe()
  }

  click = () => {
    const { records } = store.getState()

    if (this.checkbox.checked)
      store.dispatch(actions.addAll(Object.keys(records.objects)))
    else store.dispatch(actions.clear())
  }

  protected subscriber = () => {
    const { selection } = store.getState()

    this.checkbox.checked = this.hasSelection = selection.selection.length > 0
  }
}
