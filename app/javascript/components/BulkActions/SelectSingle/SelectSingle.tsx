import React, { useState } from "react"

import Checkbox from "../../Checkbox"
import useStore from "../../../hooks/useStore"

import ErrorBoundary from "../../ErrorBoundary"

interface SelectSingleProps {
  id: string
}

const SelectSingle: React.FC<SelectSingleProps> = ({ id }) => {
  const [checked, setChecked] = useState(false)

  const [update] = useStore(change => {
    if (change.selected.includes(id)) setChecked(true)
    else setChecked(false)
  })

  const updateStore = ({ target: { checked } }) => {
    if (checked) {
      update(draft => {
        draft.selected = [...draft.selected, id]
      })
    } else {
      update(draft => {
        draft.selected = draft.selected.filter(sid => sid !== id)
      })
    }
  }

  return (
    <>
      <Checkbox checked={checked} onChange={updateStore}></Checkbox>
    </>
  )
}

const Wrapped = props => (
  <ErrorBoundary>
    <SelectSingle {...props}></SelectSingle>
  </ErrorBoundary>
)

export default Wrapped
