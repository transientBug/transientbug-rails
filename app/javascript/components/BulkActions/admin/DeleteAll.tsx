import React from "react"

import { BulkActionProps } from "../types"
import { ModalClose } from "../StoreModals/modals/types"

import Turbolinks from "turbolinks"
import pluralize from "pluralize"

import Button from "../../Button"
import RecordsTable from "../../RecordsTable"

import { operations } from "../../../store/modals"
import { bulk } from "../../../api"

import { connect } from "../../../store"

const DeleteModal = (url, records, wording) => {
  const ids = records.map(r => r.i)
  const count = records.length

  const pluralString = pluralize(`${count} ${wording}`, count)

  const deleteAll = async () => {
    await bulk.delete(url, ids)
    Turbolinks.visit(window.location, { replace: true })
  }

  const actions: React.FC<{ close: ModalClose }> = close => (
    <>
      <Button
        className="self-start button-white hover:button-light-gray shadow hover:shadow-md"
        onClick={deleteAll}
      >
        Delete {pluralString}
      </Button>
      <Button
        className="hover:button-white-outline text-white hover:text-white shadow hover:shadow-md"
        onClick={close}
      >
        Cancel
      </Button>
    </>
  )

  const modalProps = {
    children: {
      title: `Delete Selected ${pluralString}}?`,
      content: (
        <>
          <p>
            Are you <strong>sure</strong> you want to delete these{" "}
            {pluralString}? This is a permanent operation and cannot be undone.
          </p>
          <RecordsTable headers={["id", "title", "uri"]} records={records} />
        </>
      ),
      actions
    }
  }

  const modalStyles = {
    dialog: "modal-light-dialogue bg-danger"
  }

  return ["Generic", modalProps, modalStyles]
}

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

  const showModal = () => show(...DeleteModal(actionUrl, records, "Bookmark"))

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

export default connect(
  ({ selection, records }) => ({
    records: selection.map(id => records[`${id}`]),
    count: selection.length
  }),
  {
    show: operations.show
  }
)(DeleteAll)
