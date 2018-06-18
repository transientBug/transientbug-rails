import { Component } from "react"
import { Button, Dropdown, Header, Icon } from 'semantic-ui-react'

import uuidv4 from "uuid/v4"

import { queryToIdHash, idHashToQuery } from "../utils"

import { Clause, Group } from "."

export class Query extends Component {
  constructor(props) {
    super(props)

    this.onAddClause = this.onAddClause.bind(this)
    this.onAddGroup = this.onAddGroup.bind(this)
    this.onRemove = this.onRemove.bind(this)
    this.onChange = this.onChange.bind(this)
  }

  updateData(data) {
    const idHash = queryToIdHash(this.props.config, this.props.data)

    const id = data.id || uuidv4()
    data.id = id

    const newData = {}
    newData[ id ] = Object.assign({}, idHash[ id ], data)

    Object.assign(idHash, newData)

    this.props.onChange(Object.assign({}, this.props.data, idHashToQuery(idHash)))
  }

  removeData(id) {
    const idHash = queryToIdHash(this.props.config, this.props.data)

    delete idHash[ id ]

    this.props.onChange(Object.assign({}, this.props.data, idHashToQuery(idHash)))
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
    return () => {
      this.updateData({
        joiner,
        must: [],
        should: [],
        must_not: []
      })
    }
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
        <Button negative basic onClick={ this.props.onRemove }><Icon trash alternate outline/> Remove Group</Button>
      )

    return (
      <div className="qb query ui list">
        { Object.entries(this.props.config.joiners).map(([joiner, joinerData]) => (
          <Group key={ joiner }>
            <Header>
              <Icon filter />
              { joinerData.display_name }
              <Dropdown>
                <Dropdown.Menu>
                  <Dropdown.Item text='Add Nested Group' icon='plus' onClick={ this.onAddGroup(joiner) } />
                  <Dropdown.Item text='Add Clause' icon='plus' onClick={ this.onAddClause(joiner) } />
                </Dropdown.Menu>
              </Dropdown>
            </Header>

            { (this.props.data[ joiner ] || []).map((clause) => {
              const newProps = {
                data: clause,
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
          </Group>
        )) }

        { removeButton }
      </div>
    )
  }
}
