import { BEHAVIOR, elementSelector } from "./constants"
import Behavior from "./Behavior"

const argsPrefix = "zob-args-"

class Zob {
  readonly behaviors: Record<string, typeof Behavior> = {}
  protected connectedBehaviors: Behavior[] = []

  constructor(behaviorsRequireContext) {
    const loadedBehaviors = behaviorsRequireContext
      .keys()
      .reduce((memo, behaviorFile) => {
        const behavior = behaviorsRequireContext(behaviorFile)["default"]

        memo[behavior[BEHAVIOR]] = behavior

        return memo
      }, {})

    this.behaviors = loadedBehaviors
  }

  Setup = () => {
    const elements = document.querySelectorAll(elementSelector)

    console.groupCollapsed(`[Zob] Connecting ${elements.length} Behaviors`)
    elements.forEach(this.setupBehavior)
    console.groupEnd()
  }

  Teardown = () => {
    console.groupCollapsed(
      `Disconnecting ${this.connectedBehaviors.length} Behaviors`
    )

    this.connectedBehaviors.forEach(behaviorInstance =>
      behaviorInstance.__teardown()
    )

    console.groupEnd()
  }

  protected setupBehavior = (element: Element) => {
    const behavior = element.getAttribute("zob-behavior")

    const args = Array.from(element.attributes)
      .filter(attr => attr.name.startsWith(argsPrefix))
      .reduce((memo, attr) => {
        const name = attr.name.substring(argsPrefix.length)
        return { ...memo, [name]: attr.value }
      }, {})

    if (!this.behaviors[behavior]) {
      console.warn(`[Zob] Unknown behavior ${behavior} for element`, element)
      return
    }

    const behaviorKlass = this.behaviors[behavior]

    console.debug(
      `[Zob] Connecting ${behavior} to element`,
      element,
      behaviorKlass,
      args
    )

    try {
      const behaviorInstance = new behaviorKlass(element, args)
      this.connectedBehaviors.push(behaviorInstance)

      behaviorInstance.__setup()
    } catch (e) {
      console.error(`[Zob] Unable to connect ${behavior}`, e)
    }
  }
}

export default Zob
