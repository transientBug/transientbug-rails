import Behavior, { ZobBehavior } from "../lib/Zob"

import dialogPolyfill from "dialog-polyfill"

@ZobBehavior("modal")
export default class ModalBehavior extends Behavior {
  Setup = () => {
    dialogPolyfill.registerDialog(this.element)

    this.element.addEventListener("close", this.cleanupClosed)
  }

  Teardown = () => {
    this.element.removeEventListener("close", this.cleanupClosed)
  }

  open = () => {
    document.body.classList.add("modaled")

    // @ts-ignore
    this.element.showModal()
  }

  close = () => {
    // @ts-ignore
    this.element.close()
  }

  protected cleanupClosed = () => {
    document.body.classList.remove("modaled")
  }
}
