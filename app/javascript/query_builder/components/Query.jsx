import React, { Component } from "react"
import uuidv4 from "uuid/v4"

import { queryToIdHash, idHashToQuery } from "../utils"

import { AddButton, RemoveButton, Clause, Group } from "."

export class Query extends Component {
  constructor(props) {
    super(props)

    this.updateData = this.updateData.bind(this)
    this.removeData = this.removeData.bind(this)

    this.onAddClause = this.onAddClause.bind(this)
    this.onAddGroup = this.onAddGroup.bind(this)
    this.onRemove = this.onRemove.bind(this)
    this.onChange = this.onChange.bind(this)
  }

  updateData(data) {
    const idHash = queryToIdHash(this.props.data)

    const id = data.id || uuidv4()
    data.id = id

    const newData = {}
    newData[ id ] = Object.assign({}, idHash[ id ], data)

    Object.assign(idHash, newData)

    this.props.onChange(Object.assign({}, this.props.data, idHashToQuery(idHash)))
  }

  removeData(id) {
    const idHash = queryToIdHash(this.props.data)

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
        <RemoveButton onClick={ this.props.onRemove }>Remove Group</RemoveButton>
      )

    return (
      <div className="qb query ui list">
        { Object.entries(this.props.config.joiners).map(([joiner, joinerData]) => (
          <Group key={ joiner }>
            <div className="header">
              { joinerData.display_name }
            </div>
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
            <AddButton onClick={ this.onAddClause(joiner) }>
              Add { joinerData.display_name } Clause
            </AddButton>
            <AddButton onClick={ this.onAddGroup(joiner) }>
              Add Group
            </AddButton>
          </Group>
        )) }

        { removeButton }
      </div>
    )
  }
}


