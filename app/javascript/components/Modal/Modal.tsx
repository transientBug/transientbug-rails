import React, { ReactNode } from "react"

import * as styles from "./Modal.module.scss"

export interface ModalProps {
  children?: {
    title?: ReactNode
    content?: ReactNode
    actions?: ReactNode
  }
  onClose: () => void
}

const Modal: React.FC<ModalProps> = ({
  children: { title, content, actions },
  onClose
}) => (
  <div className={styles.main}>
    <div className={styles.container}>
      <div className={styles.content}>
        {/* <!--Title--> */}
        <div className="flex justify-between items-center pb-3">
          <p className="text-2xl font-bold">{title}</p>
          <div className="modal-close cursor-pointer z-50" onClick={onClose}>
            <svg
              className="fill-current text-black"
              xmlns="http://www.w3.org/2000/svg"
              width="18"
              height="18"
              viewBox="0 0 18 18"
            >
              <path d="M14.53 4.53l-1.06-1.06L9 7.94 4.53 3.47 3.47 4.53 7.94 9l-4.47 4.47 1.06 1.06L9 10.06l4.47 4.47 1.06-1.06L10.06 9z"></path>
            </svg>
          </div>
        </div>
        {/* <!--Body--> */}
        <div className="my-5">{content}</div>
        {/* <!--Footer--> */}
        <div className="flex justify-end pt-2">{actions}</div>
      </div>
    </div>
  </div>
)

export default Modal
