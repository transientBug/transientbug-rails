import { useEffect } from "react"

declare global {
  interface Window {
    App: any
  }
}

const useStore = changeHandler => {
  const update = window.App.store.setState

  useEffect(() => {
    // TODO: can I make a selector like deal for this?
    const unsubscribe = window.App.store.subscribe(changeHandler)

    return () => {
      unsubscribe()
    }
  }, [])

  return update
}

export default useStore
