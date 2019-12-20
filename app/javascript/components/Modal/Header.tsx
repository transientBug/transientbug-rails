import React from "react"

import classnames from "../../lib/classnames"

interface HeaderProps {
  className?: string | string[]
}

const Header: React.FC<HeaderProps> = ({ children, className }) => (
  <div className={classnames("modal-body-header", className)}>{children}</div>
)

export default Header
