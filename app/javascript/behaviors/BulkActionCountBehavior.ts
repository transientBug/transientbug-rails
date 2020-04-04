import Behavior, { ZobBehavior, ValueBinding } from "../lib/Zob"

import store from "../store/store"

/*
I originally wanted to use lodash.template here, writing some template into the html
on the server, parsing it with template(element.innerHTML) or similar, however template
uses Function which is an implicit eval and isn't CSP safe :/

It's a toss up between this and the react component
*/
@ZobBehavior("bulk-action-count")
export default class BulkActionCountBehavior extends Behavior {
  protected unsubscribe: any

  @ValueBinding selectedCount = 0

  Setup = () => {
    this.unsubscribe = store.subscribe(this.subscriber)
  }

  Teardown = () => {
    this.unsubscribe()
  }

  protected subscriber = () => {
    const { selection } = store.getState()
    this.selectedCount = selection.selection.length
  }
}
