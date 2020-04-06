import { OBSERVERS } from "./constants"

const ValueBinding: PropertyDecorator = (target, propertyKey) => {
  const value = target[propertyKey]

  const hiddenPropertyKey = Symbol(String(propertyKey))

  Object.defineProperty(target, hiddenPropertyKey, {
    writable: true,
    enumerable: false,
    value
  })

  Object.defineProperty(target, propertyKey, {
    enumerable: true,
    get() {
      return Reflect.get(this, hiddenPropertyKey)
    },
    set(newVal) {
      if (this[OBSERVERS])
        this[OBSERVERS].forEach(observer =>
          this[observer]?.(propertyKey, newVal)
        )

      return Reflect.set(this, hiddenPropertyKey, newVal)
    }
  })
}

export default ValueBinding
