import Behavior, { ForBehavior, OnEvent } from "../lib/Behaviors"

import store, { RootState } from "../store/store"
import { actions } from "../store/slices/selections"

interface Args {
  id: string | number
}

@ForBehavior("bulk-action-select-single")
export default class BulkActionSelectSingleBehavior extends Behavior<Args> {
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
  click(event) {
    if (this.checkbox.checked) store.dispatch(actions.add(this.args.id))
    else store.dispatch(actions.remove(this.args.id))
  }

  protected subscriber = () => {
    const { selection } = store.getState() as RootState

    this.checkbox.checked = selection.selection.includes(this.args.id)
  }
}
