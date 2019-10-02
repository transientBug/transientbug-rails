import React, { useMemo, useEffect } from "react"
import ReactDOM from "react-dom"

const Portal: React.FC = ({ children }) => {
  const domNode = useMemo(() => document.createElement("div"), [])

  useEffect(() => {
    document.body.appendChild(domNode)

    return () => {
      document.body.removeChild(domNode)
    }
  })

  return ReactDOM.createPortal(children, domNode)
}

export default Portal
