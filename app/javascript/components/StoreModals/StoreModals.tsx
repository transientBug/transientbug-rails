import React from "react"

import { withErrorBoundary } from "../ErrorBoundary"
import ReactModal from "react-modal"

import Rails from "@rails/ujs"
import { CacheProvider } from "@emotion/core"
import createCache from "@emotion/cache"

import { connect } from "../../store"
import { operations } from "../../store/modals"

ReactModal.setAppElement("body")

// Sadness and not at all documented for React-Select :<
const myCache = createCache({
  nonce: Rails.cspNonce()
})

const componentRequireContext = require.context(
  "components/StoreModals/modals",
  true
)

interface StoreModalsProps {
  modal?: any
  close: (name: string) => void
}

const StoreModals: React.FC<StoreModalsProps> = ({
  modal,
  close: boundClose
}) => {
  if (!modal) return null

  let modalConstructor
  if (modal.name)
    modalConstructor = componentRequireContext(`./${modal.name}`).default

  const close = () => boundClose(modal.name)

  return (
    <CacheProvider value={myCache}>
      <ReactModal
        isOpen={!!modal.name}
        onRequestClose={close}
        overlayClassName={"modal-overlay overlay-dimmed-background"}
        className={"modal-container"}
        bodyOpenClassName={"modal-open"}
        htmlOpenClassName={"modal-open"}
      >
        {modalConstructor && modalConstructor({ close, ...modal.props })}
      </ReactModal>
    </CacheProvider>
  )
}

export default withErrorBoundary(
  connect(
    ({ modals }) => ({ modal: modals }),
    { close: operations.close }
  )(StoreModals)
)
