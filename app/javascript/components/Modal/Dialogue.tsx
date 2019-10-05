import React from "react"

import classnames from "../../lib/classnames"

interface DialogueProps {
  className?: string | string[]
}

const Dialogue: React.FC<DialogueProps> = ({ children, className }) => (
  <div className={classnames("modal-dialogue", className)}>
    <div className="modal-dialogue-body">{children}</div>
  </div>
)

export default Dialogue
