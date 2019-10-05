import React, { useState } from "react"

import useStore from "../../../hooks/useStore"

const Header: React.FC = () => {
  const [count, setCound] = useState(0)

  useStore(change => {
    setCound(change.selected.length)
  })

  if (count === 0) return null

  return (
    <>
      <h2>Bulk Actions</h2>
      <small>{count} Selected</small>
    </>
  )
}

export default Header
