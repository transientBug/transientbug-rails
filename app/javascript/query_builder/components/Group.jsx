import { Icon, Item } from "semantic-ui-react"

export const Group = (props) => (
  <Item className="qb group">
    <Icon filter />
    <div className="content">
      { props.children }
    </div>
  </Item>
)
