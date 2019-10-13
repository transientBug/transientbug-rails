import produce from "immer"

class Store {
  private subscribers = []
  private reducer = null
  private internalState: any = {}

  constructor(reducer) {
    this.reducer = reducer

    document.addEventListener("turbolinks:load", () => {
      this.reset()
    })

    this.reset()
  }

  protected reset() {
    this.internalState = {
      ...this.reducer(undefined, { type: null }),
      ...((window as any).__initStore__ || {})
    }
  }

  subscribe(subscriber) {
    this.subscribers.push(subscriber)

    return () => {
      this.unsubscribe(subscriber)
    }
  }

  unsubscribe(unsubscriber) {
    this.subscribers = this.subscribers.filter(
      subscriber => subscriber !== unsubscriber
    )
    unsubscriber = null
  }

  dispatch(event) {
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

const createReducer = (initialState, { ...typesToReducers }) => {
  return produce((draft, event) => {
    if (!typesToReducers.hasOwnProperty(event.type)) return
    typesToReducers[event.type](draft, event)
  }, initialState)
}

const combineReducers = ({ ...reducers }) => {
  return (state, event) => {
    return Object.entries(reducers).reduce((memo, [key, reducer]) => {
      return { ...memo, [key]: reducer(state, event)[key] }
    }, {})
  }
}

export default Store
export { createReducer, combineReducers }
