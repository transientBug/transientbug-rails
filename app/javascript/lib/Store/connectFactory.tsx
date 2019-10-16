import React, { useState, useMemo, useLayoutEffect, ReactNode } from "react"

import bindActions from "./bindActions"

const connectFactory = store => (mapStateToProps, mapDispatchToProps) => {
  return (Component): ReactNode => {
    const Wrapper = ({ ...ownProps }) => {
      const [stateProps, setStateProps] = useState<any>(
        mapStateToProps(store.state, ownProps)
      )

      useLayoutEffect(() => {
        const unsub = store.subscribe(state => {
          const connectorProps = mapStateToProps(state, ownProps)

          if (connectorProps !== stateProps) setStateProps(connectorProps)
        })

        return () => unsub()
      }, [mapStateToProps, ownProps])

      const dispatcherProps = useMemo(
        () => bindActions(mapDispatchToProps, store.dispatch),
        [mapDispatchToProps]
      )

      const props = {
        ...ownProps,
        ...stateProps,
        ...dispatcherProps
      }

      return <Component {...props} />
    }

    return Wrapper
  }
}

export default connectFactory
