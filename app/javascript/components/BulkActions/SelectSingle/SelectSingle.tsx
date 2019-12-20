import React from "react"

import Checkbox from "../../Checkbox"
import { withErrorBoundary } from "../../ErrorBoundary"

import { useSelector, useDispatch } from "../../../store"
import { operations } from "../../../store/selections"

interface SelectSingleProps {
  id: string
}

const SelectSingle: React.FC<SelectSingleProps> = ({ id }) => {
  const checked = useSelector(state => state.selection.includes(id)) as boolean
  const dispatch = useDispatch()

  const updateStore = ({ target: { checked } }) => {
    if (checked) dispatch(operations.add(id))
    else dispatch(operations.remove(id))
  }

  return <Checkbox checked={checked} onChange={updateStore}></Checkbox>
}

export default withErrorBoundary(SelectSingle)
