import uuidv4 from "uuid/v4"

export const pick = (obj, props) => props.reduce((a, e) => { a[ e ] = obj[ e ]; return a }, {}) // eslint-disable-line
export const entryMap = (obj, mapFunc) => Object.entries(obj).map(mapFunc)

export const queryToIdHash = (config, query) => {
  const joinerKeys = Object.keys(config.joiners)

  return Object.entries(query)
    .filter(([joiner]) => joinerKeys.includes(joiner))
    .flatMap(([joiner, joinerData]) => joinerData.flatMap((clause) => {
      if (!clause.id)
        clause.id = uuidv4() // eslint-disable-line

      if (clause.field)
        return Object.assign({ joiner }, clause)

      return Object.assign({ id: clause.id, joiner }, queryToIdHash(config, clause))
    }))
    .reduce((memo, val) => { memo[ val.id ] = val; return memo }, {}) // eslint-disable-line
}

export const idHashToQuery = (config, hash) => {
  const joinerKeys = Object.keys(config.joiners)

  const startingMemo = joinerKeys.reduce((memo, joiner) => { memo[ joiner ] = []; return memo }, {}) // eslint-disable-line

  return Object.entries(hash).reduce((memo, [_key, val]) => {
    memo[ val.joiner ] = (memo[ val.joiner ] || []) // eslint-disable-line
    memo[ val.joiner ].push(val)
    return memo
  }, startingMemo)
}
