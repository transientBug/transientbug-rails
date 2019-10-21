import railsFetch from "../railsFetch"

const bulkDelete = async (url: string, ids: string[] | number[]) => {
  return await railsFetch({
    url,
    method: "DELETE",
    payload: {
      bulk: {
        action: "delete-all",
        ids
      }
    }
  })
}

export default bulkDelete
