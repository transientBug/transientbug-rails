import React from "react"

import classnames from "../../lib/classnames"

interface ActionsProps {
  className?: string | string[]
}

const Actions: React.FC<ActionsProps> = ({ children, className }) => (
  <div className={classnames("modal-body-actions", className)}>{children}</div>
)

export default Actions
