import React, { useState } from "react"

import Checkbox from "../../Checkbox"
import useStore from "../../../hooks/useStore"

import ErrorBoundary from "../../ErrorBoundary"

const SelectAll: React.FC = () => {
  const [checked, setChecked] = useState(false)

  const update = useStore(change => {
    if (change.selected.length) setChecked(true)
    else setChecked(false)
  })

  const updateStore = ({ target: { checked } }) => {
    if (checked) {
      update(draft => {
        draft.selected = Object.keys(draft.records).map(i => parseInt(i))
      })
    } else {
      update(draft => {
        draft.selected = []
      })
    }
  }

  return <Checkbox checked={checked} onChange={updateStore}></Checkbox>
}

const Wrapped = () => (
  <ErrorBoundary>
    <SelectAll></SelectAll>
  </ErrorBoundary>
)

export default Wrapped
