const bindActions = (actions, dispatch) => {
  return Object.entries(actions).reduce((memo, [key, value]) => {
    return {
      ...memo,
      [key]: (...args) => dispatch((value as any)(...args))
    }
  }, {})
}

export default bindActions
