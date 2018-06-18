export const pick = (obj, props) => props.reduce((a, e) => (a[e] = obj[e], a), {})
export const entryMap = (obj, mapFunc) => Object.entries(obj).map(mapFunc)

export const queryToIdHash = (query) =>  Object.entries(query)
  .flatMap((joinerData, i) => {
    return joinerData[1].flatMap((clause, j) => {
      return Object.assign({ joiner: joinerData[0] }, clause)
    })
  })
  .reduce((memo, val) => { memo[ val.id ] = val; return memo }, {})

export const idHashToQuery = (hash) => Object.entries(hash).reduce((memo, [key, val]) => {
    memo[ val.joiner ] = (memo[ val.joiner ] || [])
    memo[ val.joiner ].push(val)
    return memo
  }, {})
