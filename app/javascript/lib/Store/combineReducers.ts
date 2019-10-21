const combineReducers = ({ ...reducers }) => {
  return (state, event) => {
    return Object.entries(reducers).reduce((memo, [key, reducer]) => {
      return { ...memo, [key]: reducer(state, event)[key] }
    }, {})
  }
}

export default combineReducers
