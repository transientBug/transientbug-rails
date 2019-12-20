import React from "react"
import { BulkActionProps } from "../types"

import Button from "../../Button"
import { withErrorBoundary } from "../../ErrorBoundary"

import { operations } from "../../../store/modals"
import { connect } from "../../../store"

interface RecacheAllProps {
  records: any[]
  ids: number[]
  show?: any
}

const RecacheAll: React.FC<BulkActionProps & RecacheAllProps> = ({
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
        className="button-light-gray hover:button-gray"
        onClick={showModal}
      >
        <i className="download icon" />
        Recache All
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
  )(RecacheAll)
)
