import React from "react"

import * as Modal from "../../Modal"
import { GenericModalProps } from "./types"

const GenericModal: React.FC<GenericModalProps> = ({
  close,
  children: { title, content, actions }
}) => (
  <div className="modal-dialogue light-dialogue">
    <Modal.Header>
      <h2>{title}</h2>
      <Modal.Close onClick={close} />
    </Modal.Header>
    <Modal.Content>{content}</Modal.Content>
    <Modal.Actions>
      {typeof actions === "function" ? actions(close) : actions}
    </Modal.Actions>
  </div>
)

export default GenericModal
