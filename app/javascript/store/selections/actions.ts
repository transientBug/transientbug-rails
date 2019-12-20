import types from "./types"

const add = id => ({
  type: types.ADD,
  selection: {
    id
  }
})

const remove = id => ({
  type: types.REMOVE,
  selection: {
    id
  }
})

const addAll = () => ({
  type: types.ADD_ALL
})

const clear = () => ({
  type: types.CLEAR
})

export default {
  add,
  remove,
  addAll,
  clear
}
