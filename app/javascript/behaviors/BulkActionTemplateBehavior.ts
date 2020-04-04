import Behavior, { ZobBehavior, ValueBinding } from "../lib/Zob"

import store from "../store/store"

@ZobBehavior("bulk-action-template")
export default class BulkActionTemplateBehavior extends Behavior {
  protected unsubscribe: any

  Setup = () => {
    this.unsubscribe = store.subscribe(this.subscriber)
  }

  Teardown = () => {
    this.unsubscribe()
  }

  protected subscriber = () => {
    const {
      selection: { selection }
    } = store.getState()

    for (const selected of selection) {
      const row = (this.element as HTMLTemplateElement).content.cloneNode(true)
    }
  }
}
