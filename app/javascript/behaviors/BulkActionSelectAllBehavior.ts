import Behavior, { ForBehavior, OnEvent } from "../lib/Behaviors"

import store from "../store"
import { operations } from "../store/selections"

@ForBehavior("bulk-action-select-all")
export default class BulkActionSelectAllBehavior extends Behavior<{}> {
  protected unsubscribe: any
  protected checkbox: HTMLInputElement

  OnConnect = () => {
    this.unsubscribe = store.subscribe(this.subscriber)
    this.checkbox = this.element.querySelector(`input[type=checkbox]`)
  }

  OnDisconnect = () => {
    store.unsubscribe(this.unsubscribe)
  }

  @OnEvent("click")
  click(event) {
    if (this.checkbox.checked) store.dispatch(operations.addAll())
    else store.dispatch(operations.clear())
  }

  protected subscriber = ({ selection }) => {
    this.checkbox.checked = selection.length > 0
  }
}
