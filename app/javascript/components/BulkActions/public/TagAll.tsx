import React from "react"
import { BulkActionProps } from "../types"

import Button from "../../Button"
import { withErrorBoundary } from "../../ErrorBoundary"

import { connect } from "../../../store"
import { operations } from "../../../store/modals"

interface TagAllProps {
  ids: number[]
  show?: any
  autocompleteUrl: string
}

const TagAll: React.FC<BulkActionProps & TagAllProps> = ({
  actionUrl,
  autocompleteUrl,
  count,
  show
}) => {
  if (!count) return null

  const showModal = () => show("TagAll", { url: actionUrl, autocompleteUrl })

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
    ({ selection }) => ({
      count: selection.length
    }),
    {
      show: operations.show
    }
  )(TagAll)
)
