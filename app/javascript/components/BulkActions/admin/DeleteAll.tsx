import React from "react"

import { BulkActionProps } from "../types"

import Button from "../../Button"
import { withErrorBoundary } from "../../ErrorBoundary"

import { connect } from "../../../store"
import { operations } from "../../../store/modals"

interface DeleteAllProps {
  show?: any
  count: number
}

const DeleteAll: React.FC<BulkActionProps & DeleteAllProps> = ({
  actionUrl,
  count,
  show
}) => {
  if (!count) return null

  const showModal = () => show("DeleteAll", { url: actionUrl })

  return (
    <>
      <Button
        className="button-red-outline hover:button-red"
        onClick={showModal}
      >
        <i className="trash icon" />
        Delete All
      </Button>
    </>
  )
}

export default withErrorBoundary(
  connect(
    ({ selection }) => ({
      count: selection.length
    }),
    {
      show: operations.show
    }
  )(DeleteAll)
)
