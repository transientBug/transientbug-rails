import { Component } from "react"
import { Button, Dropdown, Header, Icon, List } from 'semantic-ui-react'

import uuidv4 from "uuid/v4"

import { queryToIdHash, idHashToQuery } from "../utils"

import { Clause } from "."

export class Query extends Component {
  constructor(props) {
    super(props)

    this.onAddClause = this.onAddClause.bind(this)
    this.onAddGroup = this.onAddGroup.bind(this)
    this.onRemove = this.onRemove.bind(this)
    this.onChange = this.onChange.bind(this)
  }

  updateData(data) {
    const idHash = queryToIdHash(this.props.config, this.props.query)

    const id = data.id || uuidv4()
    data.id = id

    const newData = {}
    newData[ id ] = Object.assign({}, idHash[ id ], data)

    Object.assign(idHash, newData)

    this.props.onChange(Object.assign({}, this.props.query, idHashToQuery(idHash)))
  }

  removeData(id) {
    const idHash = queryToIdHash(this.props.config, this.props.query)

    delete idHash[ id ]

    this.props.onChange(Object.assign({}, this.props.query, idHashToQuery(idHash)))
  }

  onAddClause(joiner) {
    return () => {
      const [field, fieldData] = Object.entries(this.props.fields)[0]

      const fieldType = this.props.config.types[ fieldData.type ]
      const operation = fieldType.supported_operations[0]

      this.updateData({
        joiner,
        field,
        operation,
        values: []
      })
    }
  }

  onAddGroup(joiner) {
    return () => this.updateData({ joiner })
  }

  onRemove(id) {
    return () => this.removeData(id)
  }

  onChange(id) {
    return (data) => this.updateData(data)
  }

  render() {
    let removeButton
    if (this.props.onRemove)
      removeButton = (
        <Button negative basic icon onClick={ this.props.onRemove }>
          <Icon name='trash alternate outline'/>
          Remove Group
        </Button>
      )

    // Todo: This could probably be made to automatically group by iterating
      // and collecting the children in a Grouper component or something?
    return (
      <List className="qb query">
        { Object.entries(this.props.config.joiners).map(([joiner, joinerData]) => (
          <List.Item className="qb group" key={ joiner }>
            <List.Icon name='filter' />
            <List.Content>
              <Header>
                { joinerData.display_name }
                <Dropdown>
                  <Dropdown.Menu>
                    <Dropdown.Item text='Add Clause' icon='plus' onClick={ this.onAddClause(joiner) } />
                    <Dropdown.Item text='Add Nested Group' icon='plus' onClick={ this.onAddGroup(joiner) } />
                  </Dropdown.Menu>
                </Dropdown>
              </Header>

              { (this.props.query[ joiner ] || []).map((clause) => {
                const newProps = {
                  query: clause,
                  widgetMap: this.props.widgetMap,
                  fields: this.props.fields,
                  config: this.props.config,
                  onChange: this.onChange(clause.id),
                  onRemove: this.onRemove(clause.id),
                  key: clause.id
                }

                return ( clause.field
                  ? <Clause { ...newProps } />
                  : <Query { ...newProps } />
                )
              }) }
            </List.Content>
          </List.Item>
        )) }

        { removeButton }
      </List>
    )
  }
}
