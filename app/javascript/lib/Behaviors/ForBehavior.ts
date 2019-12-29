import { BEHAVIOR } from "./constants"

function ForBehavior(name: string) {
  return <T extends { new (...args: any[]): {} }>(constructor: T) => {
    return class extends constructor {
      static readonly [BEHAVIOR] = name
    }
  }
}

export default ForBehavior
