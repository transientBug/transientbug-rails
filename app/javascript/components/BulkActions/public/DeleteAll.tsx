import React from "react"

import { BulkActionProps } from "../types"

import Button from "../../Button"
import { withErrorBoundary } from "../../ErrorBoundary"

import { connect } from "../../../store"
import { operations } from "../../../store/modals"

interface DeleteAllProps {
  records: any[]
  ids: number[]
  show?: any
}

const DeleteAll: React.FC<BulkActionProps & DeleteAllProps> = ({
  actionUrl,
  records,
  count,
  show
}) => {
  if (!count) return null

  const showModal = () =>
    show("RecacheAll", { url: actionUrl, records, type: "Bookmark" })

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
    ({ selection, records }) => ({
      records: selection.map(id => records[`${id}`]),
      count: selection.length
    }),
    {
      show: operations.show
    }
  )(DeleteAll)
)
