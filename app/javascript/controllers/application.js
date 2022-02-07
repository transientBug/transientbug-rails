import { Application } from "@hotwired/stimulus"

const application = Application.start()

application.debug = process.env.debug
window.Stimulus   = application

export { application }
