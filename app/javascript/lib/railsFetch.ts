import Rails from "@rails/ujs"

const railsFetch = async ({
  url,
  method,
  payload
}: {
  url: string
  method: string
  payload: any
}) => {
  const csrfParam = Rails.csrfParam()
  const csrfToken = Rails.csrfToken()
  // Add rails csrf token
  payload[csrfParam] = csrfToken

  return fetch(url, {
    method: method,
    headers: new Headers({
      "Content-Type": "application/json",
      Accept: "application/json",
      "X-CSRF-Token": csrfToken,
      "X-Requested-With": "XMLHttpRequest"
    }),
    credentials: "same-origin",
    body: JSON.stringify(payload)
  })
}

export default railsFetch
