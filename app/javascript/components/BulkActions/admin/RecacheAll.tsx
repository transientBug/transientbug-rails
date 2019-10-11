import React from "react"
import { BulkAction } from "../types"

import useModal from "../../../hooks/useModal"
import useBulkActions from "../../../hooks/useBulkActions"

import * as Modal from "../../Modal"
import Button from "../../Button"

import store from "../../../lib/defaultStore"
import railsFetch from "../../../lib/railsFetch"
import Turbolinks from "turbolinks"

const RecacheAll: BulkAction = ({ actionUrl }) => {
  const visible = useBulkActions()

  const [modal, open] = useModal(close => {
    const state = store.state

    const bookmarks = state.selection.map(id => state.records[`${id}`])

    const pluralString = `${bookmarks.length} ${
      bookmarks.length === 1 ? "Bookmark" : "Bookmarks"
    }`

    const recacheAll = async () => {
      await railsFetch({
        url: actionUrl,
        method: "POST",
        payload: {
          bulk: {
            action: "delete-all",
            ids: bookmarks.map(bookmark => bookmark.id)
          }
        }
      })

      Turbolinks.visit(window.location, { action: "replace" })
    }

    return (
      <Modal.Container className="modal-dimmed-background">
        <Modal.Dialogue className="modal-light-dialogue">
          <Modal.Header>
            <h2>Recache Selected Bookmarks?</h2>
            <Modal.Close onClick={close} />
          </Modal.Header>
          <Modal.Content>
            <p>Are you sure you want to recache these {pluralString}?</p>
            <table>
              <thead>
                <tr>
                  <th>ID</th>
                </tr>
              </thead>
              <tbody>
                {bookmarks.map(bookmark => (
                  <tr key={bookmark.id}>
                    <td>{bookmark.id}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </Modal.Content>
          <Modal.Actions>
            <Button
              className="self-start button-red-outline hover:button-red shadow hover:shadow-md"
              onClick={recacheAll}
            >
              Recache {pluralString}
            </Button>
            <Button className="shadow hover:shadow-md" onClick={close}>
              Cancel
            </Button>
          </Modal.Actions>
        </Modal.Dialogue>
      </Modal.Container>
    )
  })

  if (!visible) return null

  return (
    <>
      {modal}
      <Button className="button-light-gray hover:button-gray" onClick={open}>
        <i className="download icon" />
        Recache All
      </Button>
    </>
  )
}

export default RecacheAll
