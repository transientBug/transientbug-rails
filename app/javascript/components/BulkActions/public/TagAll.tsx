import React from "react"
import { BulkActionProps } from "../types"

import Button from "../../Button"
import { withErrorBoundary } from "../../ErrorBoundary"

import { connect } from "../../../store"
import { operations } from "../../../store/modals"

interface TagAllProps {
  records: any[]
  ids: number[]
  show?: any
}

const TagAll: React.FC<BulkActionProps & TagAllProps> = ({
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
        className="button-white-outline hover:button-white text-white hover:text-gray-800"
        onClick={showModal}
      >
        <i className="tags icon" />
        Add Tags
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
  )(TagAll)
)
