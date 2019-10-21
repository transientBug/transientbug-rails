import React from "react"

import { useSelector } from "../../../store"

const Header: React.FC = () => {
  const count = useSelector(state => state.selection.length)

  if (!count) return null

  return (
    <h2>
      Bulk Actions
      <small>({count} Selected)</small>
    </h2>
  )
}

export default Header
