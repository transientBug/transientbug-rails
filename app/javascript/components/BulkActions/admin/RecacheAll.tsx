import React from "react"
import { BulkAction } from "../types"

import useBulkActions from "../../../hooks/useBulkActions"

import Button from "../../Button"

import store from "../../../store"
import { operations } from "../../../store/modals"
import { bulk } from "../../../api"
import { ModalClose } from "../StoreModals/modals/types"

const RecacheAll: BulkAction = ({ actionUrl }) => {
  const visible = useBulkActions()

  if (!visible) return null

  const bookmarks = store.state.selection.map(
    id => store.state.records[`${id}`]
  )

  const pluralString = `${bookmarks.length} ${
    bookmarks.length === 1 ? "Bookmark" : "Bookmarks"
  }`

  const recacheAll = () => bulk.recache(actionUrl, store.state.selection)

  const Actions: React.FC<{ close: ModalClose }> = close => (
    <>
      <Button
        className="self-start button-red-outline hover:button-red shadow hover:shadow-md"
        onClick={recacheAll}
      >
        Recache {pluralString}
      </Button>
      <Button className="shadow hover:shadow-md" onClick={close}>
        Cancel
      </Button>
    </>
  )

  const showModal = () => {
    const modalProps = {
      title: "Recache Selected Bookmarks?",
      content: (
        <>
          <p>Are you sure you want to recache these {pluralString}?</p>
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

    store.dispatch(operations.show("Generic", modalProps))
  }

  return (
    <>
      <Button className="button-light-gray hover:button-gray" onClick={open}>
        <i className="download icon" />
        Recache All
      </Button>
    </>
  )
}

export default RecacheAll
