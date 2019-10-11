import React, { useState } from "react"

import Checkbox from "../../Checkbox"
import useStore from "../../../hooks/useStore"

import ErrorBoundary from "../../ErrorBoundary"

import store, {
  selectionAddAll,
  selectionClear
} from "../../../lib/defaultStore"

const SelectAll: React.FC = () => {
  const [checked, setChecked] = useState(false)

  useStore(store, state => {
    if (state.selection.length) setChecked(true)
    else setChecked(false)
  })

  const updateStore = ({ target: { checked } }) => {
    if (checked) store.dispatch(selectionAddAll())
    else store.dispatch(selectionClear())
  }

  return <Checkbox inverted checked={checked} onChange={updateStore}></Checkbox>
}

const Wrapped = () => (
  <ErrorBoundary>
    <SelectAll></SelectAll>
  </ErrorBoundary>
)

export default Wrapped
