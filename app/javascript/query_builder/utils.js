export const pick = (obj, props) => props.reduce((a, e) => (a[e] = obj[e], a), {})
export const entryMap = (obj, mapFunc) => Object.entries(obj).map(mapFunc)

export const queryToIdHash = (config, query) => {
  const joinerKeys = Object.keys(config.joiners)

  return Object.entries(query)
    .filter(([joiner, joinerData]) => joinerKeys.includes(joiner))
    .flatMap(([joiner, joinerData], i) => {
      return joinerData.flatMap((clause, j) => {
        if (clause.field)
          return Object.assign({ joiner }, clause)
        return Object.assign({ id: clause.id, joiner }, queryToIdHash(config, clause))
      })
    })
    .reduce((memo, val) => { memo[ val.id ] = val; return memo }, {})
}

export const idHashToQuery = (config, hash) => {
  const joinerKeys = Object.keys(config.joiners)

  const startingMemo = joinerKeys.reduce((memo, joiner) => (memo[joiner] = [], memo), {})

  return Object.entries(hash).reduce((memo, [key, val]) => {
    memo[ val.joiner ] = (memo[ val.joiner ] || [])
    memo[ val.joiner ].push(val)
    return memo
  }, startingMemo)
}
