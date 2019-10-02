import React from "react"
import { BulkAction } from "../types"

import useModal from "../../../hooks/useModal"

import Button from "../../Button"

const DeleteAll: BulkAction = ({ actionUrl }) => {
  const [modal, open] = useModal(close => ({
    title: "Delete All?",
    content: "Are you sure you want to delete all of these bookmarks?",
    actions: (
      <>
        <Button className="button-gray hover:button-gray" onClick={close}>
          NO! Cancel! ABORT!
        </Button>
        <Button className="button-red hover:button-red" onClick={close}>
          EXTERMINATE!
        </Button>
      </>
    )
  }))

  return (
    <>
      {modal}

      <Button className="button-red-outline hover:button-red" onClick={open}>
        <i className="trash icon" />
        Delete All
      </Button>
    </>
  )
}

export default DeleteAll
