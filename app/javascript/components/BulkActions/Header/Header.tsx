import React, { useState } from "react"

import useStore from "../../../hooks/useStore"

import store from "../../../store"

const Header: React.FC = () => {
  const [count, setCound] = useState(0)

  useStore(store, state => {
    setCound(state.selection.length)
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
