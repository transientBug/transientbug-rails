import types from "./types"

const show = (name, props) => ({
  type: types.SHOW,
  modal: {
    name,
    props
  }
})

const close = name => ({
  type: types.CLOSE,
  modal: {
    name
  }
})

export default {
  show,
  close
}
