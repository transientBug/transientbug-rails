import React, { useMemo, useEffect } from "react"
import ReactDOM from "react-dom"

import Modal, { ModalProps } from "./Modal"

const ModalPortal: React.FC<ModalProps> = props => {
  const domNode = useMemo(() => document.createElement("div"), [])

  useEffect(() => {
    document.body.appendChild(domNode)

    return () => {
      document.body.removeChild(domNode)
    }
  })

  return ReactDOM.createPortal(<Modal {...props} />, domNode)
}

export default ModalPortal
