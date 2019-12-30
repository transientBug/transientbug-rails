import { BEHAVIOR } from "./constants"

function ForBehavior(name: string) {
  return <T extends { new (...args: any[]): {} }>(constructor: T) => {
    constructor[BEHAVIOR] = name

    return constructor
  }
}

export default ForBehavior
