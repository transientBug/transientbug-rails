import { EVENT_MAP } from "./constants"

const autobindId = `autobind`

function OnEvent<F extends (...args: any[]) => any>(
  event: keyof WindowEventMap
) {
  return (
    target: any,
    propertyName: string,
    descriptor: TypedPropertyDescriptor<F>
  ) => {
    const { enumerable, configurable, value } = descriptor
    const boundMethod = Symbol(`${autobindId}/${propertyName}`)

    const eventMap = target[EVENT_MAP] || {}
    eventMap[event] = propertyName

    Object.defineProperty(target, EVENT_MAP, {
      enumerable: false,
      configurable: false,
      value: eventMap
    })

    return {
      enumerable,
      configurable,

      get(this: { [boundMethod]: any }) {
        return this[boundMethod] || (this[boundMethod] = value.bind(this))
      },

      set(value: F) {
        Object.defineProperty(this, propertyName, {
          writable: true,
          enumerable: true,
          configurable: true,
          value
        })
      }
    }
  }
}

export default OnEvent
