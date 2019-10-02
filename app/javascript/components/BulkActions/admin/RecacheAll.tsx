import React from "react"
import { BulkAction } from "../types"

import useModal from "../../../hooks/useModal"

import Button from "../../Button"

const RecacheAll: BulkAction = ({ actionUrl }) => {
  const [modal, open] = useModal(close => ({
    title: "Recache All?",
    content: "Are you sure you want to recache all these bookmarks?",
    actions: (
      <>
        <Button className="button-gray hover:button-gray" onClick={close}>
          Cancel!
        </Button>
        <Button className="button-red hover:button-red" onClick={close}>
          Recache!
        </Button>
      </>
    )
  }))

  return (
    <>
      {modal}

      <Button className="button-gray hover:button-gray" onClick={open}>
        <i className="download icon" />
        Recache All
      </Button>
    </>
  )
}

export default RecacheAll
