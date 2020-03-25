import { ReactNode } from "react"

interface ModalClose {
  (): void
}

export interface GenericModalProps {
  close: ModalClose
  children: {
    title: ReactNode
    content: ReactNode
    actions: (close: ModalClose) => ReactNode
  }
}
