import produce from "immer"

function createStore(initialState = {}) {
  let listeners = []
  const state = { ...initialState }

  function unsubscribe(unsubListener) {
    listeners = listeners.filter(listener => listener !== unsubListener)
    unsubListener = null
  }

  function setState(action) {
    const newState = produce(state, action)
    Object.assign(state, newState)

    listeners.forEach(listener => listener(state))
  }

  return {
    subscribe(listener) {
      listeners.push(listener)
      return () => unsubscribe(listener)
    },
    unsubscribe,
    setState,
    getState() {
      return state
    }
  }
}

export default createStore
