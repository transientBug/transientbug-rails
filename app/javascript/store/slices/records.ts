import { createSlice } from "@reduxjs/toolkit"

import { reset } from "./resetAction"

interface RecordsState {
  objects: any
  type: string
  attributes: any[]
}

const initialState: RecordsState = Object.freeze({
  objects: {},
  type: "",
  attributes: []
})

const { name, reducer, actions } = createSlice({
  name: "records",
  initialState,
  reducers: {
    reset: _state => initialState
  },
  extraReducers: {
    [reset.toString()]: (state, { payload }) => ({
      ...initialState,
      ...payload.records
    })
  }
})

export { name, reducer, actions }
