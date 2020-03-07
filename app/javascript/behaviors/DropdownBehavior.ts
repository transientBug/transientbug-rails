import Behavior, { OnEvent, ForBehavior } from "../lib/Behaviors"

interface Args {
  active?: string
  targetToggle?: string
}

@ForBehavior("dropdown")
export default class DropdownBehavior extends Behavior<Args> {
  protected menu: any

  OnConnect = () => {
    this.menu = this.element.nextElementSibling
  }

  @OnEvent("click")
  click(event: MouseEvent) {
    event.preventDefault()

    const isHidden = this.menu.classList.toggle(
      this.args.targetToggle || "hidden"
    )

    if (!this.args.active) return
    this.element.classList.toggle(this.args.active, !isHidden)
  }
}
