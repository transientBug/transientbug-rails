import types from "./types"

const show = (name, props, styles = {}) => ({
  type: types.SHOW,
  modal: {
    name,
    props,
    styles: {
      dialog: "modal-light-dialogue",
      ...styles
    }
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
