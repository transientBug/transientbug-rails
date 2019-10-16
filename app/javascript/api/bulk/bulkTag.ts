import railsFetch from "../railsFetch"

const bulkTag = async (url, ids, tags) => {
  return await railsFetch({
    url,
    method: "PATCH",
    payload: {
      bulk: {
        action: "tag-all",
        ids,
        tags
      }
    }
  })
}

export default bulkTag
