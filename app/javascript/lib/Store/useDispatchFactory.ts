const useDispatchFactory = store => () => {
  return store.dispatch
}

export default useDispatchFactory
