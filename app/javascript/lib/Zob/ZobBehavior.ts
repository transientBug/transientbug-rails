import { BEHAVIOR_KEY } from "./constants"

function ZobBehavior(name: string) {
  return <T extends { new (...args: any[]): {} }>(constructor: T) => {
    Object.defineProperty(constructor, BEHAVIOR_KEY, {
      writable: false,
      value: name
    })

    return constructor
  }
}

export default ZobBehavior
