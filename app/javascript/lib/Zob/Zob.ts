import { BEHAVIOR_KEY, elementSelector, ZOB_INSTANCE } from "./constants"
import Behavior from "./Behavior"

class Zob {
  readonly behaviors: Record<string, typeof Behavior> = {}
  protected connectedBehaviors: Behavior[] = []

  constructor(behaviorsRequireContext) {
    const loadedBehaviors = behaviorsRequireContext
      .keys()
      .reduce((memo, behaviorFile) => {
        const behavior = behaviorsRequireContext(behaviorFile)["default"]

        memo[behavior[BEHAVIOR_KEY]] = behavior

        return memo
      }, {})

    this.behaviors = loadedBehaviors
  }

  Setup = () => {
    const elements = document.querySelectorAll(elementSelector)

    console.group(`[Zob] Connecting ${elements.length} Behaviors`)
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

    if (!this.behaviors[behavior]) {
      console.warn(`[Zob] Unknown behavior ${behavior} for element`, element)
      return
    }

    const behaviorKlass = this.behaviors[behavior]

    console.debug(
      `[Zob] Connecting ${behavior} to element`,
      element,
      behaviorKlass
    )

    try {
      const behaviorInstance = new behaviorKlass(element)
      element[ZOB_INSTANCE] = behaviorInstance
      this.connectedBehaviors.push(behaviorInstance)

      behaviorInstance.__setup()
    } catch (e) {
      console.error(`[Zob] Unable to connect ${behavior}`, e)
    }
  }
}

export default Zob
