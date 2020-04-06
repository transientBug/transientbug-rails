import Behavior, { ZobBehavior, ValueBinding } from "../lib/Zob"

import store from "../store/store"
import { actions } from "../store/slices/selections"

@ZobBehavior("bulk-action-select-single")
export default class BulkActionSelectSingleBehavior extends Behavior {
  protected unsubscribe: any
  protected checkbox: HTMLInputElement

  @ValueBinding isSelected = false

  Setup = () => {
    this.unsubscribe = store.subscribe(this.subscriber)
    this.checkbox = this.element.querySelector(`input[type=checkbox]`)
    this.checkbox.onclick = this.click
  }

  Teardown = () => {
    this.unsubscribe()
  }

  click = () => {
    // if (this.checkbox.checked) store.dispatch(actions.add(this.args.id))
    // else store.dispatch(actions.remove(this.args.id))
  }

  protected subscriber = () => {
    const { selection } = store.getState()

    // this.checkbox.checked = this.isSelected = selection.selection.includes(
    //   this.args.id
    // )
  }
}
