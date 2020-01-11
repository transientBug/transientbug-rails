import Behavior, { ForBehavior, OnEvent } from "../lib/Behaviors"

import store from "../store"
import { operations } from "../store/selections"

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
    store.unsubscribe(this.unsubscribe)
  }

  @OnEvent("click")
  click(event) {
    if (this.checkbox.checked) store.dispatch(operations.add(this.args.id))
    else store.dispatch(operations.remove(this.args.id))
  }

  protected subscriber = ({ selection }) => {
    this.checkbox.checked = selection.includes(this.args.id)
  }
}
