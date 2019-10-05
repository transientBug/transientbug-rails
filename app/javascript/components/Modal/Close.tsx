import React from "react"

interface CloseProps {
  onClick: () => void
}

const Close: React.FC<CloseProps> = ({ onClick }) => (
  <button className="modal-header-close" onClick={onClick}>
    <i className="close icon" />
  </button>
)

export default Close
