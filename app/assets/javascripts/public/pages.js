document.addEventListener("turbolinks:load", () => {
  if (!($(".pages.index").length > 0)) {
    return
  }
})

document.addEventListener("turbolinks:load", () => {
  if (!($(".pages.extension_pair").length > 0)) {
    return
  }

  const dimmer = $(".ui.active.dimmer")
  let timeout = setTimeout(() => {
    dimmer.remove()
    $("#error").removeClass("hidden")
  }, 10000)

  const auth_data = dimmer.data()
  console.log("Data for content script upon handshake", auth_data)

  function messageContentScript() {
    window.postMessage({
      sender: "page-script",
      type: "auth_data",
      message: auth_data
    }, "*")
  }

  const handlers = {
    handshake: (event) => {
      console.log("Got handshake from content script, sending creds", event)
      messageContentScript()
    },

    ack: (event) => {
      console.log("Got ack from content script, removing dimmer", event)
      dimmer.children(".text").text("Authed!")
      setTimeout(() => {
        dimmer.remove()
        $("#success").removeClass("hidden")
        clearTimeout(timeout)
      }, 1500)
    }
  }

  window.addEventListener("message", (event) => {
    if(event.source == window &&
       event.data &&
       event.data.sender == "content-script") {
      handlers[event.data.type](event)
    }
  })
})
