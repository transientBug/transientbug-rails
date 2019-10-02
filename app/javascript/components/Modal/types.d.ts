import { ReactNode } from "react"

export interface ModalProps {
  children?: {
    title?: ReactNode
    content?: ReactNode
    actions?: ReactNode
  }
  onClose: () => void
}
