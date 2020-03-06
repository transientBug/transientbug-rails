import railsFetch from "../railsFetch"

const bulkRecache = async (url, ids) => {
  return await railsFetch({
    url,
    method: "POST",
    payload: {
      bulk: {
        action: "recache-all",
        ids
      }
    }
  })
}

export default bulkRecache
