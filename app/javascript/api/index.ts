import * as bulk from "./bulk"
import railsFetch from "./railsFetch"

export { bulk }
export { default as request } from "./railsFetch"

const get = async url => {
  return await railsFetch({
    url,
    method: "GET"
  })
}

export { get }
