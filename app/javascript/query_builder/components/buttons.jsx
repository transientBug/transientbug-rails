import React from "react"

export const RemoveButton = (props) => (
  <button className={ ["ui tiny basic negative button", (props.children ? "" : "icon")].join(" ") } { ...props } >
    <i className="trash icon" />
    { props.children }
  </button>
)

export const AddButton = (props) => (
  <button className={ ["ui tiny button", (props.children ? "" : "icon")].join(" ") } { ...props } >
    <i className="plus icon" />
    { props.children }
  </button>
)
