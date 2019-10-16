class Store {
  protected subscribers = []
  protected reducer = null
  protected internalState: any = {}

  constructor(reducer) {
    this.reducer = reducer

    this.reset()
  }

  protected reset = () => {
    this.internalState = {
      ...this.reducer(undefined, { type: null })
    }
  }

  subscribe = subscriber => {
    this.subscribers.push(subscriber)

    return () => {
      this.unsubscribe(subscriber)
    }
  }

  unsubscribe = unsubscriber => {
    this.subscribers = this.subscribers.filter(
      subscriber => subscriber !== unsubscriber
    )
    unsubscriber = null
  }

  dispatch = event => {
    if (typeof event === "function") return event(ev => this.dispatch(ev))

    this.internalState = this.reducer(this.internalState, event)

    this.subscribers.forEach(subscriber =>
      subscriber(this.internalState, event)
    )
  }

  get state() {
    return this.internalState
  }
}

export default Store
