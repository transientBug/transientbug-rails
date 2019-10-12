import React, { useState } from "react"

import Checkbox from "../../Checkbox"
import useStore from "../../../hooks/useStore"

import ErrorBoundary from "../../ErrorBoundary"

import store from "../../../store"

import { operations } from "../../../store/selections"

const SelectAll: React.FC = () => {
  const [checked, setChecked] = useState(false)

  useStore(store, state => {
    if (state.selection.length) setChecked(true)
    else setChecked(false)
  })

  const updateStore = ({ target: { checked } }) => {
    if (checked) store.dispatch(operations.addAll())
    else store.dispatch(operations.clear())
  }

  return <Checkbox inverted checked={checked} onChange={updateStore}></Checkbox>
}

const Wrapped = () => (
  <ErrorBoundary>
    <SelectAll></SelectAll>
  </ErrorBoundary>
)

export default Wrapped
