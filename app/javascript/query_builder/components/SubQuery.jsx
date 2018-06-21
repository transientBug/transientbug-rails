import { Component } from "react"
import { Button, Dropdown, Header, Icon, List } from 'semantic-ui-react'

import uuidv4 from "uuid/v4"

import { queryToIdHash, idHashToQuery } from "../utils"
import { isNil } from "lodash"

import { Clause } from "."

export class SubQuery extends Component {
  updateQueryData(func) {
    const idHash = queryToIdHash(this.props.config, this.props.query)

    const resultIdHash = func(idHash)

    const query = idHashToQuery(this.props.config, resultIdHash)

    return Object.assign({}, this.props.query, query)
  }

  updateData(data) {
    const newQuery = this.updateQueryData((idHash) => {
      const id = data.id || uuidv4()
      data.id = id

      const newData = {}
      newData[ id ] = Object.assign({}, idHash[ id ], data)

      return Object.assign(idHash, newData)
    })

    this.props.onChange(newQuery)
  }

  removeData(id) {
    const newQuery = this.updateQueryData((idHash) => {
      delete idHash[ id ]
      return idHash
    })

    this.props.onChange(newQuery)
  }

  onAddClause = (joiner) => {
    return () => {
      const [field, fieldData] = Object.entries(this.props.config.fields)[0]
      const operation = fieldData.default_operation

      this.updateData({
        joiner,
        field,
        operation,
        values: []
      })
    }
  }

  onAddGroup = (joiner) => { return () => this.updateData({ joiner }) }

  onRemove = (id) => { return () => this.removeData(id) }

  onChange = (id) => { return (data) => this.updateData(data) }

  render() {
    // Todo: This could probably be made to automatically group by iterating
    // and collecting the children in a Grouper component or something?
    return (
      <List className="qb sub query">
        { Object.entries(this.props.config.joiners).map(([joiner, joinerData]) => (
          <List.Item className={ ["qb clause group", joiner].join(" ") } key={ joiner }>
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
                clause.joiner = joiner

                const newProps = {
                  query: clause,
                  config: this.props.config,
                  onChange: this.onChange(clause.id),
                  onRemove: this.onRemove(clause.id),
                  key: clause.id,
                  root: (this.props.root + `[${ joiner }][]`)
                }

                return (
                  clause.field
                    ? <Clause { ...newProps } />
                    : (
                      <div key={ clause.id }>
                        <input type='hidden' name={ this.props.root + `[${ joiner }][][id]` } value={ clause.id } />
                        <SubQuery { ...newProps } />
                      </div>
                    )
                )
              }) }
            </List.Content>
          </List.Item>
        )) }

        { (this.props.onRemove
          && <Button negative basic icon onClick={ this.props.onRemove }>
              <Icon name='trash alternate outline'/>
              Remove Group
            </Button>) }
      </List>
    )
  }
}
