import { createReducer } from "../../lib/Store"

import types from "./types"

const reducer = createReducer(
  { modals: {} },
  {
    [types.SHOW]: (draft, action) => {
      draft.modals = { ...action.modal }
    },
    [types.CLOSE]: (draft, action) => {
      draft.modals = {}
    }
  }
)

export default reducer
