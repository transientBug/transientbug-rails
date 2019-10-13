import Store, { combineReducers } from "../lib/Store"

import selection from "./selections"
import records from "./records"
import modals from "./modals"

const appReducer = combineReducers({ selection, records, modals })

const applicationStore = new Store(appReducer)

export default applicationStore
