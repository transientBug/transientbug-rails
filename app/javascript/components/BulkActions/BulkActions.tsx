import React, { useState, useCallback, ReactNode } from "react"

import ErrorBoundary from "../ErrorBoundary"
import Button from "../Button"
import Modal from "../Modal"

import * as styles from "./BulkActions.module.scss"

interface UseModalHook {
  (props: any): [ReactNode, () => void, () => void]
}

const useModal: UseModalHook = props => {
  const [opened, setOpened] = useState(false)

  const open = useCallback(() => setOpened(true), [])
  const close = useCallback(() => setOpened(false), [])

  return [opened && <Modal onClose={close}>{props(close)}</Modal>, open, close]
}

interface ActionHandlerProps {
  actionUrl: string
}

type ActionHandler = React.FC<ActionHandlerProps>

const RecacheAll: ActionHandler = ({ actionUrl }) => {
  const [modal, open, close] = useModal(close => ({
    title: "Recache All?",
    content: "Are you sure you want to recache all these bookmarks?",
    actions: (
      <>
        <Button className="button-gray hover:button-gray" onClick={close}>
          Cancel!
        </Button>
        <Button className="button-red hover:button-red" onClick={close}>
          Recache!
        </Button>
      </>
    )
  }))

  return (
    <>
      {modal}
      <Button className="button-gray hover:button-gray" onClick={open}>
        <i className="download icon" />
        Recache All
      </Button>
    </>
  )
}

const DeleteAll: ActionHandler = ({ actionUrl }) => {
  const [modal, open, close] = useModal(close => ({
    title: "Delete All?",
    content: "Are you sure you want to delete all of these bookmarks?",
    actions: (
      <>
        <Button className="button-gray hover:button-gray" onClick={close}>
          NO! Cancel! ABORT!
        </Button>
        <Button className="button-red hover:button-red" onClick={close}>
          EXTERMINATE!
        </Button>
      </>
    )
  }))

  return (
    <>
      {modal}

      <Button className="button-red-inverted hover:button-red" onClick={open}>
        <i className="trash icon" />
        Delete All
      </Button>
    </>
  )
}

const ActionsMap: { [key: string]: React.FC<ActionHandlerProps> } = {
  "recache-all": RecacheAll,
  "delete-all": DeleteAll
}

interface ActionHash {
  [key: string]: string
}

interface BulkActionProps {
  actions?: ActionHash[]
}

const BulkActions: React.FC<BulkActionProps> = ({ actions }) => {
  console.log(actions)

  const actionHandlers = actions.map((actionHash, idx) => {
    const actionName = Object.keys(actionHash)[0]
    const actionUrl = actionHash[actionName]

    const ActionHandler = ActionsMap[actionName]

    return <ActionHandler key={idx} actionUrl={actionUrl} />
  })

  return (
    <div className={styles.container}>
      <div className={styles.content}>
        <h2>Bulk Actions</h2>
        {actionHandlers}
      </div>
    </div>
  )
}

const Wrapped = props => (
  <ErrorBoundary>
    <BulkActions {...props} />
  </ErrorBoundary>
)

export default Wrapped
