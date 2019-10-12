import types from "./types"

const set = records => ({
  type: types.SET,
  records
})

const clear = () => ({
  type: types.CLEAR
})

export default {
  set,
  clear
}
