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

  buildRequest({url, method, payload}) {
    const csrfParam = Rails.csrfParam()
    const csrfToken = Rails.csrfToken()
    // Add rails csrf token
    payload[ csrfParam ] = csrfToken

    return fetch(url, {
      method: method,
      headers: new Headers({
        "Content-Type": "application/json",
        "Accept": "application/json",
        "X-CSRF-Token": csrfToken,
        "X-Requested-With": "XMLHttpRequest"
      }),
      credentials: "same-origin",
      body: JSON.stringify(payload)
    })
  }
}

Application.boot()

App.registerInitializer("action cable", (app) => {
  app.cable = ActionCable.createConsumer()
})
;
