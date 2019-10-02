import React from "react"
import { ModalProps } from "./types"

import * as styles from "./Modal.module.scss"

const Modal: React.FC<ModalProps> = ({
  children: { title, content, actions },
  onClose
}) => (
  <div className={styles.main}>
    <div className={styles.container}>
      <div className={styles.content}>
        {/* <!--Title--> */}
        <div className={styles.header}>
          <p className={styles.title}>{title}</p>
          <div className={styles.close} onClick={onClose}>
            <i className="close icon" />
          </div>
        </div>
        {/* <!--Body--> */}
        <div className={styles.body}>{content}</div>
        {/* <!--Footer--> */}
        <div className={styles.actions}>{actions}</div>
      </div>
    </div>
  </div>
)

export default Modal
