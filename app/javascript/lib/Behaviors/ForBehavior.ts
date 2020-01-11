import { BEHAVIOR } from "./constants"

function ForBehavior(name: string) {
  return <T extends { new (...args: any[]): {} }>(constructor: T) => {
    Object.defineProperty(constructor, BEHAVIOR, {
      writable: false,
      value: name
    })

    return constructor
  }
}

export default ForBehavior
