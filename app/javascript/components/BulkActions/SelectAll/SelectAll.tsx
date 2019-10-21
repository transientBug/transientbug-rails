import React, { ReactNode } from "react"

import Checkbox from "../../Checkbox"
import { withErrorBoundary } from "../../ErrorBoundary"

import { useSelector, useDispatch } from "../../../store"
import { operations } from "../../../store/selections"

interface SelectAllProps {
  label?: ReactNode
}

const SelectAll: React.FC<SelectAllProps> = ({ label }) => {
  const checked = useSelector(state => state.selection.length !== 0) as boolean
  const dispatch = useDispatch()

  const updateStore = ({ target: { checked } }) => {
    if (checked) dispatch(operations.addAll())
    else dispatch(operations.clear())
  }

  return (
    <Checkbox inverted checked={checked} onChange={updateStore}>
      {label}
    </Checkbox>
  )
}

export default withErrorBoundary(SelectAll)
