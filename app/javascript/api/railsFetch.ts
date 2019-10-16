import Rails from "@rails/ujs"

const railsFetch = async ({
  url,
  method,
  payload
}: {
  url: string
  method: string
  payload?: any
}) => {
  const csrfToken = Rails.csrfToken()

  const options: any = {
    method,
    headers: new Headers({
      "Content-Type": "application/json",
      Accept: "application/json",
      "X-CSRF-Token": csrfToken,
      "X-Requested-With": "XMLHttpRequest"
    }),
    credentials: "same-origin"
  }

  if (method !== "GET" && method !== "HEAD" && payload) {
    const csrfParam = Rails.csrfParam()
    payload[csrfParam] = csrfToken

    options.body = JSON.stringify(payload)
  }

  return fetch(url, options)
}

export default railsFetch
