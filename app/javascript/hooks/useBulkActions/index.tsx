import { useState } from "react"

import useStore from "../useStore"

const useBulkActions = () => {
  const [visible, setVisible] = useState(false)

  useStore(change => {
    setVisible(change.selected.length !== 0)
  })

  return visible
}

export default useBulkActions
