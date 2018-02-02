class Application {
  static boot() {
    window.App || (window.App = new Application())
    document.addEventListener("turbolinks:load", () => {
      App.init()
      App.connect()
    })

    document.addEventListener("turbolinks:visit", () => {
      App.disconnect()
    })
  }

  constructor() {
    this._initialized = false
    this._initializers = []

    this._domWires = []
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
