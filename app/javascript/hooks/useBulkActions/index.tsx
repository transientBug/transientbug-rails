import { useState } from "react"

import useStore from "../useStore"

import store from "../../store"

const useBulkActions = () => {
  const [visible, setVisible] = useState(false)

  useStore(store, state => {
    setVisible(state.selection.length !== 0)
  })

  return visible
}

export default useBulkActions
