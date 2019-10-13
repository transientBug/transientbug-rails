import React, { ReactNode, useRef } from "react"

import * as Modal from "../../../Modal"
import { GenericModalProps } from "./types"

const GenericModal: React.FC<GenericModalProps> = ({
  close,
  children: { title, content, actions }
}) => (
  <Modal.Container className="modal-dimmed-background">
    <Modal.Dialogue className="modal-light-dialogue">
      <Modal.Header>
        <h2>{title}</h2>
        <Modal.Close onClick={close} />
      </Modal.Header>
      <Modal.Content>{content}</Modal.Content>
      <Modal.Actions>{actions(close)}</Modal.Actions>
    </Modal.Dialogue>
  </Modal.Container>
)

export default GenericModal
