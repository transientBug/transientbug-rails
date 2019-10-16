import railsFetch from "../railsFetch"

const bulkTag = async (url, ids) => {
  return await railsFetch({
    url,
    method: "PATCH",
    payload: {
      bulk: {
        action: "tag-all",
        ids
      }
    }
  })
}

export default bulkTag
