import React from "react"
import { BulkAction } from "../types"

import useBulkActions from "../../../hooks/useBulkActions"

import Button from "../../Button"

import store from "../../../store"
import { operations } from "../../../store/modals"

import railsFetch from "../../../lib/railsFetch"
import Turbolinks from "turbolinks"
import ErrorBoundary from "../../ErrorBoundary"
import { ModalClose } from "../StoreModals/modals/types"

const TagAll: BulkAction = ({ actionUrl }) => {
  const visible = useBulkActions()

  if (!visible) return null

  const bookmarks = store.state.selection.map(
    id => store.state.records[`${id}`]
  )

  const pluralString = `${bookmarks.length} ${
    bookmarks.length === 1 ? "Bookmark" : "Bookmarks"
  }`

  const tagAll = async () => {
    await railsFetch({
      url: actionUrl,
      method: "PATCH",
      payload: {
        bulk: {
          action: "tag-all",
          ids: bookmarks.map(bookmark => bookmark.id)
        }
      }
    })

    Turbolinks.visit(window.location, { action: "replace" })
  }

  const Actions: React.FC<{ close: ModalClose }> = close => (
    <>
      <Button
        className="self-start button-white hover:button-gray hover:text-black shadow hover:shadow-md"
        onClick={tagAll}
      >
        Add Tags
      </Button>
      <Button
        className="hover:button-light-gray-outline text-black hover:text-black shadow hover:shadow-md"
        onClick={close}
      >
        Cancel
      </Button>
    </>
  )

  const showModal = () => {
    const modalProps = {
      children: {
        title: "Add Tags to Selected Bookmarks",
        content: (
          <>
            <p>
              Any tags specified here will be added to the selected{" "}
              {pluralString}.
            </p>
          </>
        ),
        actions: Actions
      }
    }

    store.dispatch(operations.show("Generic", modalProps))
  }

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

const Wrapped: typeof TagAll = ({ ...props }) => (
  <ErrorBoundary>
    <TagAll {...props} />
  </ErrorBoundary>
)

export default Wrapped
