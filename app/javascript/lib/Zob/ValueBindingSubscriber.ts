import { OBSERVERS } from "./constants"

const ValueBindingSubscriber: PropertyDecorator = (target, propertyKey) => {
  ;(target[OBSERVERS] = target[OBSERVERS] || []).push(propertyKey)
}

export default ValueBindingSubscriber
