import { createReducer } from "../../lib/Store"

import types from "./types"

const reducer = createReducer(
  { records: {} },
  {
    [types.SET]: (draft, action) => {
      action.records.forEach(record => {
        draft.records[record.id] = record
      })
    },
    [types.CLEAR]: draft => {
      draft.records = []
    }
  }
)

export default reducer
