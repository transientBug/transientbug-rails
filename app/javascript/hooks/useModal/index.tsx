import React, { ReactNode, useState, useCallback, useMemo } from "react"

import Modal from "../../components/Modal"
import Portal from "../../components/Portal"

export interface UseModalHook {
  (props: any): [ReactNode, () => void, () => void]
}

const useModal: UseModalHook = props => {
  const [opened, setOpened] = useState(false)

  const open = useCallback(() => setOpened(true), [])
  const close = useCallback(() => setOpened(false), [])

  const modal = useMemo(
    () =>
      opened && (
        <Portal>
          <Modal onClose={close}>{props(close)}</Modal>
        </Portal>
      ),
    [opened]
  )

  return [modal, open, close]
}

export default useModal
