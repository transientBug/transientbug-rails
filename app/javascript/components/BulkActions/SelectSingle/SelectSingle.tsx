import React, { useState } from "react"

import Checkbox from "../../Checkbox"
import useStore from "../../../hooks/useStore"

import ErrorBoundary from "../../ErrorBoundary"

import store, { selectionAdd, selectionRemove } from "../../../lib/defaultStore"

interface SelectSingleProps {
  id: string
}

const SelectSingle: React.FC<SelectSingleProps> = ({ id }) => {
  const [checked, setChecked] = useState(false)

  useStore(store, state => {
    if (state.selection.includes(id)) setChecked(true)
    else setChecked(false)
  })

  const updateStore = ({ target: { checked } }) => {
    if (checked) store.dispatch(selectionAdd(id))
    else store.dispatch(selectionRemove(id))
  }

  return <Checkbox checked={checked} onChange={updateStore}></Checkbox>
}

const Wrapped = props => (
  <ErrorBoundary>
    <SelectSingle {...props}></SelectSingle>
  </ErrorBoundary>
)

export default Wrapped
