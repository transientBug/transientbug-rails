class Application {
  constructor(apis) {
    this._apis = apis
    this._inited = false
    this._registeredInits = []

    this._currentInits = []

    this.cable = ActionCable.createConsumer()
  }

  registerInit(klass) {
    this._registeredInits.push(klass)
  }

  init() {
    // Cleanup things, #destroy should remove event handlers and anything that
    // might keep a reference to the object around, causing a memory leak
    this._currentInits.forEach((initer) => {
      if("destroy" in initer)
        initer.destroy()
    })

    delete this._currentInits
    this._currentInits = []

    this._currentInits = this._registeredInits.map((initer) => new initer())

    if(this._inited)
      return

    $.fn.api.settings.api = this._apis

    $.fn.api.settings.cache = false
    $.fn.api.settings.debug = true
    $.fn.api.settings.verbose = true

    this._inited = true
  }
}
