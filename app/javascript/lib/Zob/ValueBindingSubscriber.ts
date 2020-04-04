import { OBSERVABLES } from "./constants"

const ValueBindingSubscriber: PropertyDecorator = (target, propertyKey) => {
  ;(target[OBSERVABLES] = target[OBSERVABLES] || []).push(propertyKey)
}

export default ValueBindingSubscriber
