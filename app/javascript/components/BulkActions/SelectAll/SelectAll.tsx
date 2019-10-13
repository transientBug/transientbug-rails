import React, { useState, ReactNode } from "react"

import Checkbox from "../../Checkbox"
import useStore from "../../../hooks/useStore"

import ErrorBoundary from "../../ErrorBoundary"

import store from "../../../store"

import { operations } from "../../../store/selections"

interface SelectAllProps {
  label?: ReactNode
}

const SelectAll: React.FC<SelectAllProps> = ({ label }) => {
  const [checked, setChecked] = useState(false)

  useStore(store, state => {
    if (state.selection.length) setChecked(true)
    else setChecked(false)
  })

  const updateStore = ({ target: { checked } }) => {
    if (checked) store.dispatch(operations.addAll())
    else store.dispatch(operations.clear())
  }

  return (
    <Checkbox inverted checked={checked} onChange={updateStore}>
      {label}
    </Checkbox>
  )
}

const Wrapped: typeof SelectAll = props => (
  <ErrorBoundary>
    <SelectAll {...props} />
  </ErrorBoundary>
)

export default Wrapped
