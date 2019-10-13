import React, { ReactNode } from "react"

import * as Modal from "../../../Modal"
import { GenericModalProps } from "./types"

const DangerModal: React.FC<GenericModalProps> = ({
  close,
  children: { title, content, actions }
}) => (
  <Modal.Container className="modal-dimmed-background">
    <Modal.Dialogue className="modal-dark-dialogue bg-danger">
      <Modal.Header>
        <h2>{title}</h2>
        <Modal.Close onClick={close} />
      </Modal.Header>
      <Modal.Content>{content}</Modal.Content>
      <Modal.Actions>{actions(close)}</Modal.Actions>
    </Modal.Dialogue>
  </Modal.Container>
)

export default DangerModal
