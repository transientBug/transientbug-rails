import React from "react"

import { BulkAction } from "../types"
import { ModalClose } from "../StoreModals/modals/types"

import Turbolinks from "turbolinks"

import useBulkActions from "../../../hooks/useBulkActions"

import Button from "../../Button"
import ErrorBoundary from "../../ErrorBoundary"

import store from "../../../store"
import { operations } from "../../../store/modals"

import railsFetch from "../../../api/railsFetch"

const DeleteAll: BulkAction = ({ actionUrl }) => {
  const visible = useBulkActions()

  if (!visible) return null

  const bookmarks = store.state.selection.map(
    id => store.state.records[`${id}`]
  )

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

  const Actions: React.FC<{ close: ModalClose }> = close => (
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

  const showModal = () => {
    const modalProps = {
      children: {
        title: "Delete Selected Bookmarks?",
        content: (
          <>
            <p>
              Are you <strong>sure</strong> you want to delete these{" "}
              {pluralString}? This is a permanent operation and cannot be
              undone.
            </p>
            <table>
              <thead>
                <tr>
                  <th>ID</th>
                  <th>Title</th>
                  <th>URL</th>
                </tr>
              </thead>
              <tbody>
                {bookmarks.map(bookmark => (
                  <tr key={bookmark.id}>
                    <td>{bookmark.id}</td>
                    <td>{bookmark.title}</td>
                    <td>{bookmark.uri}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </>
        ),
        actions: Actions
      }
    }

    const modalStyles = {
      dialog: "modal-light-dialogue bg-danger"
    }

    store.dispatch(operations.show("Generic", modalProps, modalStyles))
  }

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

const Wrapped: typeof DeleteAll = ({ ...props }) => (
  <ErrorBoundary>
    <DeleteAll {...props} />
  </ErrorBoundary>
)

export default Wrapped
