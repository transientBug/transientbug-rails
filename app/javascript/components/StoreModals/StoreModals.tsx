import React from "react"

import { withErrorBoundary } from "../ErrorBoundary"
import ReactModal from "react-modal"

import Rails from "@rails/ujs"
import { CacheProvider } from "@emotion/core"
import createCache from "@emotion/cache"

import { connect } from "react-redux"
import { actions } from "../../store/slices/modals"
import { RootState } from "../../store/store"

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

  let ModalComponent
  if (modal.name)
    ModalComponent = componentRequireContext(`./${modal.name}`).default

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
        {ModalComponent && <ModalComponent {...{ close, ...modal }} />}
      </ReactModal>
    </CacheProvider>
  )
}

// prettier-ignore
export default withErrorBoundary(
  connect(
    ({ modals }: RootState) => ({ modal: modals.stack[0] }),
    { close: actions.close }
  )(StoreModals)
)
