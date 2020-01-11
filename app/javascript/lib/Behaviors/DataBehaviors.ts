import { BEHAVIOR } from "./constants"

class DataBehaviors {
  readonly Selector = `[data-behavior]`

  readonly behaviors = {}
  protected connectedBehaviors = []

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

  connect = () => {
    const elements = document.querySelectorAll(this.Selector)
    console.groupCollapsed(`Connecting ${elements.length} Behaviors`)
    elements.forEach(this.connectBehavior)
    console.groupEnd()
  }

  disconnect = () => {
    console.groupCollapsed(
      `Disconnecting ${this.connectedBehaviors.length} Behaviors`
    )
    this.connectedBehaviors.forEach(behaviorInstance =>
      behaviorInstance.disconnect()
    )
    console.groupEnd()
  }

  protected connectBehavior = element => {
    const { behavior, args: argsJSON } = element.dataset

    if (!this.behaviors[behavior]) {
      console.warn(`Unknown behavior ${behavior} for element`, element)
      return
    }

    const args = {}
    if (argsJSON) Object.assign(args, JSON.parse(argsJSON))

    const behaviorKlass = this.behaviors[behavior]

    console.debug(
      `Connecting ${behavior} to element`,
      element,
      behaviorKlass,
      args
    )

    try {
      const behaviorInstance = new behaviorKlass(element, args)
      this.connectedBehaviors.push(behaviorInstance)

      behaviorInstance.connect()
    } catch (e) {
      console.error(`Unable to connect ${behavior}`, e)
    }
  }
}

export default DataBehaviors
