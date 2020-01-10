import { EVENT_MAP } from "./constants"

class Behavior<S> {
  static readonly OnBehavior: string

  constructor(readonly element: HTMLElement, readonly args: S) {}

  OnConnect = () => {}
  OnDisconnect = () => {}

  connect = () => {
    this.connectEventListeners()
    this.OnConnect()
  }

  disconnect = () => {
    this.disconnectEventListeners()
    this.OnDisconnect()
  }

  private connectEventListeners = () => {
    if (!this[EVENT_MAP]) return

    Object.entries(this[EVENT_MAP]).forEach(([eventName, handler]) => {
      this.element.addEventListener(eventName, this[handler as string])
    })
  }

  private disconnectEventListeners = () => {
    if (!this[EVENT_MAP]) return

    Object.entries(this[EVENT_MAP]).forEach(([eventName, handler]) => {
      this.element.removeEventListener(eventName, this[handler as string])
    })
  }
}

export default Behavior
