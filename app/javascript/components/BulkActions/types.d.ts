export interface BulkActionProps {
  actionUrl: string
  visible: boolean
  count?: number
}

export type BulkAction = React.FC<BulkActionProps>
