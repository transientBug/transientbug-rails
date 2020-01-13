import { createSlice } from "@reduxjs/toolkit"

import { reset } from "./resetAction"

interface ModalsState {
  // TODO: type modals
  stack: any[]
}

const initialState: ModalsState = Object.freeze({
  stack: []
})

const { name, reducer, actions } = createSlice({
  name: "modals",
  initialState,
  reducers: {
    reset: _state => initialState,
    open: (state, { payload }) => {
      state.stack.push(payload)
    },
    close: state => {
      // TODO: allow closing a specific modal
      state.stack.pop()
    }
  },
  extraReducers: {
    [reset.toString()]: _ => initialState
  }
})

export { name, reducer, actions }
