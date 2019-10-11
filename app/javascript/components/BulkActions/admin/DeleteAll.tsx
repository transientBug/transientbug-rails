import React from "react"
import { BulkAction } from "../types"

import useModal from "../../../hooks/useModal"
import useBulkActions from "../../../hooks/useBulkActions"

import * as Modal from "../../Modal"
import Button from "../../Button"

import store from "../../../lib/defaultStore"
import railsFetch from "../../../lib/railsFetch"
import Turbolinks from "turbolinks"

const DeleteAll: BulkAction = ({ actionUrl }) => {
  const visible = useBulkActions()

  const [modal, open] = useModal(close => {
    const state = store.state

    const bookmarks = state.selection.map(id => state.records[`${id}`])

    const pluralString = `${bookmarks.length} ${
      bookmarks.length === 1 ? "Bookmark" : "Bookmarks"
    }`

    const deleteAll = async () => {
      await railsFetch({
        url: actionUrl,
        method: "DELETE",
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
        <Modal.Dialogue className="modal-dark-dialogue bg-danger">
          <Modal.Header>
            <h2>Delete Selected Bookmarks?</h2>
            <Modal.Close onClick={close} />
          </Modal.Header>
          <Modal.Content>
            <p>
              Are you <strong>sure</strong> you want to delete these{" "}
              {pluralString}? Deleting users data should be handled with care
              and only used for extreme circumstances or if requested. This is a
              permanent operation.
            </p>
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
        </Modal.Dialogue>
      </Modal.Container>
    )
  })

  if (!visible) return null

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
