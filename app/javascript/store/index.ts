import Store, { combineReducers } from "../lib/Store"

import selection from "./selections"
import records from "./records"

const appReducer = combineReducers({ selection, records })

const applicationStore = new Store(appReducer)

export default applicationStore
