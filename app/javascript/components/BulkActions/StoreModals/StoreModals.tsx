import React from "react"

import { connect } from "../../../store"
import { operations } from "../../../store/modals"

import { withErrorBoundary } from "../../ErrorBoundary"

import ReactModal from "react-modal"
import classnames from "../../../lib/classnames"

ReactModal.setAppElement("body")

const componentRequireContext = require.context(
  "components/BulkActions/StoreModals/modals",
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
      <div className="modal-dialogue-body">
        {modalConstructor && modalConstructor({ close, ...modal.props })}
      </div>
    </ReactModal>
  )
}

const Wrapped = withErrorBoundary(
  connect(
    ({ modals = {} }) => ({ modal: modals }),
    { close: operations.close }
  )(StoreModals)
)

export default Wrapped
