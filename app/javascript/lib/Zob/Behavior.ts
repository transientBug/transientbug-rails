import { walk } from "./utils"
import { ZOB_INSTANCE } from "./constants"
import ValueBindingSubscriber from "./ValueBindingSubscriber"

const zobPrefix = "zob-"

const normalizeAttributeName = (name: string) => {
  if (name.startsWith("@")) return name.replace("@", "zob-on:")
  if (name.startsWith(":")) return name.replace(":", "zob-bind:")

  return name
}

const zobAttributes = (element: Element) =>
  Array.from(element.attributes)
    .map(attr => {
      const name = normalizeAttributeName(attr.name)

      if (!name.startsWith(zobPrefix)) return null

      const [directive, key] = name.substring(zobPrefix.length).split(":", 2)
      const { value } = attr

      return {
        directive,
        key,
        value
      }
    })
    .filter(Boolean)

class Behavior {
  protected args: Record<string, string> = {}

  constructor(readonly element: Element) {
    this.args = zobAttributes(this.element)
      .filter(({ directive }) => directive === "arg")
      .reduce((memo, { key, value }) => ({ ...memo, [key]: value }), {})

    this.setupEventListeners(this.element)
  }

  walkWithoutNested = (
    element: Element,
    callback: (element: Element, attributes: any) => void | boolean
  ) => {
    walk(element, el => {
      if (el[ZOB_INSTANCE]) return false

      // if (el.hasAttribute("zob-behavior")) {
      //   el[ZOB_INSTANCE] = new Behavior(el)
      //   return false
      // }

      const zobibutes = zobAttributes(el).filter(
        ({ directive }) => directive !== "behavior"
      )

      return callback(el, zobibutes)
    })
  }

  setupEventListeners = (el: Element) => {
    this.walkWithoutNested(el, (element, attributes) => {
      attributes.forEach(({ directive, key, value }) => {
        if (directive !== "on") return

        const callee = this[value]
        console.log(`event: ${key} => ${value}`, callee, this)

        element.addEventListener(key, callee)
      })
    })
  }

  updateDataBindings = (el: Element) => {
    this.walkWithoutNested(el, (element, attributes) => {
      attributes.forEach(({ directive, key, value }) => {
        if (directive !== "bind") return

        const callee = this[value]
        console.log(`bind: ${key} => ${value}`, callee, this)

        switch (key) {
          case "class":
            const cssClassesToValues = JSON.parse(value) as Record<
              string,
              string
            >

            Object.entries(cssClassesToValues).forEach(([cssClass, val]) => {
              element.classList.toggle(cssClass, this[val])
            })
            break
          case "text":
            element.textContent = callee
            break
          case "html":
            element.innerHTML = callee
            break
          default:
            element.setAttribute(key, callee)
        }
      })
    })
  }

  Setup = () => {}
  Teardown = () => {}

  __setup = () => {
    this.Setup()
  }

  __teardown = () => {
    // TODO handle cleanup of bindings from #connect
    this.Teardown()
  }

  @ValueBindingSubscriber UpdateBindings = (prop: string, value: any) =>
    this.updateDataBindings(this.element)
}

export default Behavior
