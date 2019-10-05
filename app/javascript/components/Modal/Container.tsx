import React from "react"

import classnames from "../../lib/classnames"

interface ContainerProps {
  className?: string | string[]
}

const Container: React.FC<ContainerProps> = ({ children, className }) => (
  <div className={classnames("modal-container", className)}>{children}</div>
)

export default Container
