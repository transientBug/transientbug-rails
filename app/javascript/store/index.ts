import Store, {
  combineReducers,
  connectFactory,
  useStoreFactory,
  useSelectorFactory,
  useDispatchFactory
} from "../lib/Store"

import selection from "./selections"
import records from "./records"
import modals from "./modals"

class DOMStore extends Store {
  constructor(reducer) {
    super(reducer)

    document.addEventListener("turbolinks:load", () => {
      this.reset()
    })
  }

  protected reset = () => {
    this.internalState = {
      ...this.reducer(undefined, { type: null }),
      ...((window as any).__initStore__ || {})
    }
  }
}

const appReducer = combineReducers({ selection, records, modals })
const applicationStore = new DOMStore(appReducer)

const connect = connectFactory(applicationStore)

const useStore = useStoreFactory(applicationStore)
const useSelector = useSelectorFactory(applicationStore)

const useDispatch = useDispatchFactory(applicationStore)

export default applicationStore
export { connect, useStore, useSelector, useDispatch }
