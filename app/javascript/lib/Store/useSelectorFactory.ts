import { useState, useLayoutEffect } from "react"

const useSelectorFactory = store => selector => {
  const [selectedValue, setSelectedValue] = useState<any>(selector(store.state))

  useLayoutEffect(() => {
    const unsub = store.subscribe(state => {
      const possibleNewValue = selector(state)

      if (possibleNewValue !== selectedValue) setSelectedValue(possibleNewValue)
    })

    return () => unsub()
  })

  return selectedValue
}

export default useSelectorFactory
