import React, { useState } from "react"

import useStore from "../../../hooks/useStore"

import store from "../../../store"

const Header: React.FC = () => {
  const [count, setCount] = useState(0)

  useStore(store, state => {
    setCount(state.selection.length)
  })

  if (count === 0) return null

  return (
    <>
      <h2>
        Bulk Actions
        <small>({count} Selected)</small>
      </h2>
    </>
  )
}

export default Header
