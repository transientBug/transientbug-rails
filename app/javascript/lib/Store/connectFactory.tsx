import React, { useState, useMemo, useLayoutEffect } from "react"

import bindActions from "./bindActions"

const connectFactory = store => (mapStateToProps, mapDispatchToProps) => {
  return (Component): React.FC => {
    return ({ ...ownProps }) => {
      const [stateProps, setStateProps] = useState<any>({})

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
  }
}

export default connectFactory
