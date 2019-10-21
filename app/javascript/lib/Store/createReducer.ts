import produce from "immer"

const createReducer = (initialState, { ...typesToReducers }) => {
  return produce((draft, event) => {
    if (!typesToReducers.hasOwnProperty(event.type)) return
    typesToReducers[event.type](draft, event)
  }, initialState)
}

export default createReducer
