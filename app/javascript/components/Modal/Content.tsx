import React from "react"

import classnames from "../../lib/classnames"

interface ContentProps {
  className?: string | string[]
}

const Content: React.FC<ContentProps> = ({ children, className }) => (
  <div className={classnames("modal-body-content", className)}>{children}</div>
)

export default Content
