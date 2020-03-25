import React from "react"
import { ModalClose } from "./types"

import * as Modal from "../../Modal"
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
  ids: number[]
  wording: string
}

type RecacheAllModalProps = OwnProps & StateProps

const RecacheAllModal: React.FC<RecacheAllModalProps> = ({
  close,
  ids,
  wording,
  url
}) => {
  const count = ids.length

  const pluralString = pluralize(`${count} ${wording}`, count)

  const recacheAll = async () => {
    await bulk.recache(url, ids)
    Turbolinks.visit(window.location, { replace: true })
  }

  return (
    <div className="modal-dialogue light-dialogue">
      <Modal.Header>
        <h2>Recache Selected {pluralString}?</h2>
        <Modal.Close onClick={close} />
      </Modal.Header>
      <Modal.Content>
        <p>
          Are you <strong>sure</strong> you want to recache these {pluralString}
          ? This could cause service interruptions or cause existing good caches
          to be replaced with broken caches if the sites have moved or gone
          down.
        </p>
      </Modal.Content>
      <Modal.Actions>
        <Button
          className="self-start button-gray-outline hover:button-light-gray shadow hover:shadow-md"
          onClick={recacheAll}
        >
          Recache {pluralString}
        </Button>
        <Button
          className="button-white hover:button-light-gray shadow hover:shadow-md"
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
    wording: records.type
  }),
  {}
)(RecacheAllModal)
