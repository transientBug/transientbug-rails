import { createReducer } from "../../lib/Store"

import types from "./types"

const reducer = createReducer(
  { selection: [] },
  {
    [types.ADD]: (draft, action) => {
      draft.selection.push(parseInt(action.selection.id))
    },
    [types.REMOVE]: (draft, action) => {
      draft.selection = draft.selection.filter(
        id => id !== parseInt(action.selection.id)
      )
    },
    [types.ADD_ALL]: draft => {
      draft.selection = Object.keys(draft.records).map(i => parseInt(i))
    },
    [types.CLEAR]: draft => {
      draft.selection = []
    }
  }
)

export default reducer
