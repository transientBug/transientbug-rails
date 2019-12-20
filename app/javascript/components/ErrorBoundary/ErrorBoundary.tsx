import React, { Component } from "react"

interface State {
  hasError: boolean
  error: any // eslint-disable-line
}

class ErrorBoundary extends Component {
  state: State = { hasError: false, error: null }

  static getDerivedStateFromError(error: any) {
    return { hasError: true, error }
  }

  componentDidCatch(error: any, info: any) {
    console.error(error, info)
  }

  render() {
    const { children } = this.props
    const { hasError, error } = this.state

    if (!hasError) return children

    const { message = "Unknown error" } = error

    return (
      <>
        <p>Something went wrong!</p>
        <p>{message}</p>
      </>
    )
  }
}

export default ErrorBoundary
