import { List } from "semantic-ui-react"

import GrouperHeader from "./GrouperHeader"

const Grouper = ({ children }) => {
  const childrenArray = React.Children.toArray(children)

  const headers = childrenArray.filter(i => i.type === GrouperHeader)
  const items = childrenArray.filter(i => i.type !== GrouperHeader)

  const groups = items.reduce((memo, header) => {
    const { group } = header.props

    /* eslint no-param-reassign:0 */
    if (!memo[ group ])
      memo[ group ] = []

    memo[ group ].push(header)

    return memo
  }, {})

  return (
    <List className="qb sub query">
      { headers.map(header => (
        <List.Item className={ ["qb clause group", header.props.group].join(" ") } key={ header.props.group }>
          <List.Icon name="filter" />
          <List.Content>
            { header }
            { groups[ header.props.group ] && groups[ header.props.group ].map(elem => elem) }
          </List.Content>
        </List.Item>
      )) }

      <List.Item>
        { groups[ undefined ] && groups[ undefined ] }
      </List.Item>
    </List>
  )
}

export default Grouper
