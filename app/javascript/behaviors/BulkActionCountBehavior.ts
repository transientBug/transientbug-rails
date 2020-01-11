import Behavior, { ForBehavior } from "../lib/Behaviors"

import store from "../store"

/*
I originally wanted to use lodash.template here, writing some template into the html
on the server, parsing it with template(element.innerHTML) or similar, however template
uses Function which is an implicit eval and isn't CSP safe :/

It's a toss up between this and the react component
*/
@ForBehavior("bulk-action-count")
export default class BulkActionCountBehavior extends Behavior<{}> {
  protected unsubscribe: any

  OnConnect = () => {
    this.unsubscribe = store.subscribe(this.subscriber)
  }

  OnDisconnect = () => {
    store.unsubscribe(this.unsubscribe)
  }

  protected subscriber = ({ selection }) => {
    this.element.innerHTML = selection.length
  }
}
