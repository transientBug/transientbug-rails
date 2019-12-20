import { createReducer } from "../../lib/Store"

import types from "./types"

const reducer = createReducer(
  {
    records: {
      objects: {},
      type: "",
      attributes: []
    }
  },
  {
    [types.SET]: (draft, action) => {
      action.records.forEach(record => {
        draft.records.objects[record.id] = record
      })
    },
    [types.CLEAR]: draft => {
      draft.records.objects = {}
    }
  }
)

export default reducer
