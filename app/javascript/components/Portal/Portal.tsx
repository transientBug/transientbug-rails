import React, { useMemo, useEffect, ReactNode } from "react"
import ReactDOM from "react-dom"

interface PortalProps {
  children: ReactNode
  to?: HTMLElement
}

const Portal: React.FC<PortalProps> = ({ children, to }) => {
  const domNode = useMemo(() => to || document.createElement("div"), [to])

  useEffect(() => {
    if (to) return

    document.body.appendChild(domNode)

    return () => {
      document.body.removeChild(domNode)
    }
  }, [to])

  return ReactDOM.createPortal(children, domNode)
}

export default Portal
