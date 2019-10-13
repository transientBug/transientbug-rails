import React from "react"
import KeyboardShortcut from "../KeyboardShortcut"

interface CloseProps {
  onClick: () => void
}

const Close: React.FC<CloseProps> = ({ onClick }) => (
  <button className="modal-header-close" onClick={onClick}>
    <KeyboardShortcut keys={["esc"]} onKey={onClick} />
    <i className="close icon" />
  </button>
)

export default Close
