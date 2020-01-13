import {
  configureStore,
  combineReducers,
  getDefaultMiddleware
} from "@reduxjs/toolkit"

import logger from "redux-logger"

import { reducer as recordsReducer } from "./slices/records"
import { reducer as selectionsReducer } from "./slices/selections"
import { reducer as modalsReducer } from "./slices/modals"

const rootReducer = combineReducers({
  records: recordsReducer,
  selection: selectionsReducer,
  modals: modalsReducer
})

const customizedMiddleware = getDefaultMiddleware()

const middleware = [...customizedMiddleware]
if (process.env.NODE_ENV !== "production") middleware.push(logger)

const store = configureStore({
  reducer: rootReducer,
  middleware,
  devTools: process.env.NODE_ENV !== "production"
})

export type RootState = ReturnType<typeof rootReducer>
export type AppDispatch = typeof store.dispatch

export default store
