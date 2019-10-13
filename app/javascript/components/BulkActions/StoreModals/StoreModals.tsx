import React, { useState, useRef } from "react"

import store from "../../../store"
import useStore from "../../../hooks/useStore"
import { operations } from "../../../store/modals"

import Portal from "../../Portal"
import ErrorBoundary from "../../ErrorBoundary"

const componentRequireContext = require.context(
  "components/BulkActions/StoreModals/modals",
  true
)

const StoreModals: React.FC = () => {
  const [modal, setModal] = useState<any>({})

  useStore(store, state => {
    if (modal !== state.modals) setModal(state.modals)
  })

  if (!modal.name) return null

  const modalConstructor = componentRequireContext(`./${modal.name}`).default

  const close = () => store.dispatch(operations.close(modal.name))

  return <Portal>{modalConstructor({ store, close, ...modal.props })}</Portal>
}

const Wrapped = () => (
  <ErrorBoundary>
    <StoreModals />
  </ErrorBoundary>
)

export default Wrapped
