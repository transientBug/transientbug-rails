class Application {
  static boot() {
    window.App || (window.App = new Application())
  }

  constructor() {
    this._initialized = false
    this._initializers = []

    this._domWires = []

    document.addEventListener("turbolinks:load", () => {
      this.init()
      this.connect()
    })

    document.addEventListener("turbolinks:visit", () => {
      this.disconnect()
    })
  }

  registerInitializer(key, callback) {
    this._initializers.push({ key: key, callback: callback })
  }

  registerDOMWire(klass) {
    this._domWires.push(new klass())
  }

  init() {
    if(this._initialized)
      return

    this._initializers.forEach(({callback}) => callback(this))

    this._initialized = true
  }

  disconnect() {
    this._domWires.forEach((wire) => {
      if("disconnect" in wire)
        wire.disconnect()
    })
  }

  connect() {
    this._domWires.map((wire) => wire.connect())
  }
}

Application.boot()

App.registerInitializer("action cable", (app) => {
  app.cable = ActionCable.createConsumer()
})
;
