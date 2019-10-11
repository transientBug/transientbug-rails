import { useEffect } from "react"

const useStore = (store, changeHandler) => {
  useEffect(() => {
    // TODO: can I make a selector like deal for this?
    const unsubscribe = store.subscribe(changeHandler)

    return () => {
      unsubscribe()
    }
  }, [])
}

export default useStore
