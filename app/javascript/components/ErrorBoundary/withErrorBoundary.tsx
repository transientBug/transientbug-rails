import React, { ReactNode } from "react"

import ErrorBoundary from "./ErrorBoundary"

const withErrorBoundary = (Component): ReactNode => {
  const Wrapper = props => (
    <ErrorBoundary>
      <Component {...props} />
    </ErrorBoundary>
  )

  return Wrapper
}

export default withErrorBoundary
