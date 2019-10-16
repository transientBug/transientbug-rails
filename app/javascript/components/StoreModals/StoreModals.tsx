import React from "react"

import { withErrorBoundary } from "../ErrorBoundary"
import ReactModal from "react-modal"

import classnames from "../../lib/classnames"

import { connect } from "../../store"
import { operations } from "../../store/modals"

ReactModal.setAppElement("body")

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
    <ReactModal
      isOpen={!!modal.name}
      onRequestClose={close}
      overlayClassName={"modal-container modal-dimmed-background"}
      className={classnames(
        "modal-dialogue",
        modal.name ? modal.styles.dialog : ""
      )}
      bodyOpenClassName={"modal-open"}
      htmlOpenClassName={"modal-open"}
    >
      {modalConstructor && modalConstructor({ close, ...modal.props })}
    </ReactModal>
  )
}

export default withErrorBoundary(
  connect(
    ({ modals }) => ({ modal: modals }),
    { close: operations.close }
  )(StoreModals)
)
