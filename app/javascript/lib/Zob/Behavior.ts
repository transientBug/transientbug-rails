import { walk } from "./utils"
import { ZOB } from "./constants"
import ValueBindingSubscriber from "./ValueBindingSubscriber"

const zobPrefix = "zob-"

class Binding {
  readonly binders: Record<string, string> = {}

  constructor(
    readonly element: Element,
    readonly attributeToChange: string,
    binderValue: string
  ) {
    if (attributeToChange === "class")
      this.binders = Object.entries(
        JSON.parse(binderValue) as Record<string, string>
      ).reduce((memo, [cssClass, onChangeValue]) => {
        return { ...memo, [onChangeValue]: cssClass }
      }, {})
    else this.binders = { [binderValue]: "__default" }
  }

  change = (valueName: string, value: any) => {
    const binder = this.binders[valueName]

    if (!binder) return

    switch (this.attributeToChange) {
      case "class":
        this.element.classList.toggle(binder, value)
        break
      case "text":
        this.element.textContent = value
        break
      case "html":
        this.element.innerHTML = value
        break
      default:
        this.element.setAttribute(this.attributeToChange, value)
    }
  }
}

class Behavior<S = {}> {
  targets: Record<string, Element | undefined> = {}
  bindings: Binding[] = []

  constructor(readonly element: Element, readonly args: S) {
    this[ZOB] = this
  }

  Setup = () => {}
  Teardown = () => {}

  __setup = () => {
    walk(this.element, el => {
      Array.from(el.attributes).forEach(attr => {
        let name = attr.name
        if (name.startsWith("@")) name = name.replace("@", "zob-on:")
        if (name.startsWith(":")) name = name.replace(":", "zob-bind:")

        if (!name.startsWith(zobPrefix)) return

        const [action, key] = name.substring(zobPrefix.length).split(":", 2)
        const { value } = attr

        const caller = this[value]

        if (action === "behavior" || action.startsWith("args")) return

        switch (action) {
          case "target":
            this.targets[value] = el
            break
          case "on":
            el.addEventListener(key, caller)
            break
          case "bind":
            this.bindings.push(new Binding(el, key, value))
            break
          default:
            console.warn("Unknown action", action)
        }
      })
    })

    this.Setup()

    this.bindings.forEach(binding => {
      Object.keys(binding.binders).forEach(valueName => {
        console.log("reseting", valueName, this[valueName])
        binding.change(valueName, this[valueName])
      })
    })
  }

  __teardown = () => {
    // TODO handle cleanup of bindings from #connect
    this.Teardown()
  }

  @ValueBindingSubscriber UpdateBindings = (prop: string, value: any) =>
    this.bindings.forEach(binding => binding.change(prop, value))
}

export default Behavior
