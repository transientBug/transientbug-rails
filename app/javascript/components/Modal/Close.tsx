import React from "react"

import Kbd from "../Kbd"

interface CloseProps {
  onClick: () => void
}

const Close: React.FC<CloseProps> = ({ onClick }) => (
  <button className="modal-header-close" onClick={onClick}>
    <Kbd>esc</Kbd>
    <i className="close icon" />
  </button>
)

export default Close
