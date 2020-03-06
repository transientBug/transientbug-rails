import React from "react"
import { ModalClose } from "./types"

import * as Modal from "../../Modal"
import RecordsTable from "../../RecordsTable"
import Button from "../../Button"

import { bulk } from "../../../api"

import Turbolinks from "turbolinks"
import pluralize from "pluralize"

import { connect } from "react-redux"
import { RootState } from "../../../store/store"

interface OwnProps {
  close: ModalClose
  url: string
}

interface StateProps {
  records: any[]
  ids: number[]
  headers: string[]
  wording: string
}

type DeleteAllModalProps = OwnProps & StateProps

const DeleteAllModal: React.FC<DeleteAllModalProps> = ({
  close,
  records,
  ids,
  headers,
  wording,
  url
}) => {
  const count = records.length

  const pluralString = pluralize(`${count} ${wording}`, count)

  const deleteAll = async () => {
    await bulk.delete(url, ids)
    Turbolinks.visit(window.location, { replace: true })
  }

  return (
    <div className="modal-dialogue light-dialogue bg-danger">
      <Modal.Header>
        <h2>Delete Selected {pluralString}?</h2>
        <Modal.Close onClick={close} />
      </Modal.Header>
      <Modal.Content>
        <p>
          Are you <strong>sure</strong> you want to delete these {pluralString}?
          This is a permanent operation and cannot be undone.
        </p>
        <RecordsTable headers={headers} records={records} />
      </Modal.Content>
      <Modal.Actions>
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
      </Modal.Actions>
    </div>
  )
}

export default connect(
  ({ records, selection }: RootState) => ({
    ids: selection.selection,
    records: selection.selection.map(i => records.objects[`${i}`]),
    headers: records.attributes,
    wording: records.type
  }),
  {}
)(DeleteAllModal)
