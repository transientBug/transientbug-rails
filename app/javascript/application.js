// Entry point for the build script in your package.json
import "@hotwired/turbo-rails"
import * as ActionCable from "@rails/actioncable"

ActionCable.logger.enabled = true

import "./controllers"
import "./components"
