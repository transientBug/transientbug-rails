import { createSlice } from "@reduxjs/toolkit"

import { reset } from "./resetAction"

interface SelectionsState {
  // TODO: type this
  selection: any[]
}

const initialState: SelectionsState = Object.freeze({
  selection: []
})

const { name, reducer, actions } = createSlice({
  name: "selections",
  initialState,
  reducers: {
    reset: _state => initialState,
    add: (state, { payload }) => {
      state.selection.push(payload)
    },
    remove: (state, { payload }) => {
      state.selection = state.selection.filter(id => id !== payload)
    },
    addAll: (state, { payload }) => {
      state.selection = state.selection.concat(payload)
    },
    clear: state => {
      state.selection = []
    }
  },
  extraReducers: {
    [reset.toString()]: _ => initialState
  }
})

export { name, reducer, actions }
