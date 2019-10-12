import React, { useState } from "react"

import Checkbox from "../../Checkbox"
import useStore from "../../../hooks/useStore"

import ErrorBoundary from "../../ErrorBoundary"

import store from "../../../store"
import { operations } from "../../../store/selections"

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
    if (checked) store.dispatch(operations.add(id))
    else store.dispatch(operations.remove(id))
  }

  return <Checkbox checked={checked} onChange={updateStore}></Checkbox>
}

const Wrapped = props => (
  <ErrorBoundary>
    <SelectSingle {...props}></SelectSingle>
  </ErrorBoundary>
)

export default Wrapped
