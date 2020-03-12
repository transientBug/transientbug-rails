import Rails from "@rails/ujs"
import Turbolinks from "turbolinks"
import * as ActiveStorage from "@rails/activestorage"

Rails.start()
Turbolinks.start()
ActiveStorage.start()

/**
 * Turbolinks and inline body script tags with a CSP nonce don't seem to play nice.
 * Probably not recommended to do this but :/ Nothing else it working
 *
 * this is a vanilla version of whats documented here
 * https://github.com/turbolinks/turbolinks/issues/430
 */
document.addEventListener("turbolinks:request-start", event => {
  const xhr = event.data.xhr
  xhr.setRequestHeader("X-Turbolinks-Nonce", Rails.cspNonce())
})
