import Store, { createReducer, combineReducers } from "./Store"

const windowState = (window as any).__initStore__ || {}

const SELECTION_ADD = "selection.add"
const SELECTION_REMOVE = "selection.remove"
const SELECTION_ADD_ALL = "selection.add_all"
const SELECTION_CLEAR = "selection.clear"

const RECORDS_SET = "records.set"
const RECORDS_CLEAR = "records.clear"

const selectionAdd = id => ({
  type: SELECTION_ADD,
  selection: {
    id
  }
})

const selectionRemove = id => ({
  type: SELECTION_REMOVE,
  selection: {
    id
  }
})

const selectionAddAll = () => ({
  type: SELECTION_ADD_ALL
})

const selectionClear = () => ({
  type: SELECTION_CLEAR
})

const recordsSet = records => ({
  type: RECORDS_SET,
  records
})

const recordsClear = () => ({
  type: RECORDS_CLEAR
})

const selection = createReducer(
  { selection: [] },
  {
    [SELECTION_ADD]: (draft, action) => {
      draft.selection.push(parseInt(action.selection.id))
    },
    [SELECTION_REMOVE]: (draft, action) => {
      delete draft.selection[parseInt(action.selection.id)]
    },
    [SELECTION_ADD_ALL]: draft => {
      draft.selection = Object.keys(draft.records).map(i => parseInt(i))
    },
    [SELECTION_CLEAR]: draft => {
      draft.selection = []
    }
  }
)

const records = createReducer(
  { records: windowState.records || {} },
  {
    [RECORDS_SET]: (draft, action) => {
      action.records.forEach(record => {
        draft.records[record.id] = record
      })
    },
    [RECORDS_CLEAR]: draft => {
      draft.records = []
    }
  }
)

const appReducer = combineReducers({ selection, records })

const defaultStore = new Store(appReducer)

export default defaultStore
export {
  selectionAdd,
  selectionRemove,
  selectionAddAll,
  selectionClear,
  recordsSet,
  recordsClear
}
