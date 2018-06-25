import { Component } from "react"
import { Button, Dropdown, Header, Icon, List } from 'semantic-ui-react'

import uuidv4 from "uuid/v4"

import { isNil, isObject } from "lodash"

import { Clause } from "."

const Grouper = ({ children }) => {
  const childrenArray = React.Children.toArray(children)

  const headers = childrenArray.filter((i) => i.type === Header)
  const items = childrenArray.filter((i) => i.type !== Header)

  const groups = items.reduce((memo, header) => {
    const group = header.props.group
    if (!memo[ group ])
      memo[ group ] = []

    memo[ group ].push(header)

    return memo
  }, {})

  console.dir(groups)

  return (
    <List className="qb sub query">
      { headers.map((header) => {
        const group = header.props.group

        return (
          <List.Item className={ ["qb clause group", group].join(" ") } key={ group }>
            <List.Icon name='filter' />
            { header }
            <List.Content>
              { groups[ group ].map((elem) => elem) }
            </List.Content>
          </List.Item>
        )
      }) }

      { groups[ undefined ] }
    </List>
  )
}

export class SubQuery extends Component {
  updateQueryData(func) {
    return Object.assign({}, this.props.query, func(this.props.query))
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
      const [[field, fieldData], ...tail] = Object.entries(this.props.config.fields)
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
    const clauses = Object.entries(this.props.query).filter(([k, v]) => isObject(v))
    const headers = Object.entries(this.props.config.joiners)

    return (
      <React.Fragment>
        { (this.props.query.joiner
          && <input type='hidden' name={ this.props.root + `[${ this.props.query.joiner }][][ this.props.query.id ]` } value={ this.props.query.id } />) }

        <Grouper>
          { headers.map(([joiner, joinerData]) => (
            <Header group={ joiner }>
              { joinerData.display_name }
              <Dropdown>
                <Dropdown.Menu>
                  <Dropdown.Item text='Add Clause' icon='plus' onClick={ this.onAddClause(joiner) } />
                  <Dropdown.Item text='Add Nested Group' icon='plus' onClick={ this.onAddGroup(joiner) } />
                </Dropdown.Menu>
              </Dropdown>
            </Header>
          )) }

          { clauses.map(([id, clause]) => {
            const newProps = {
              query: clause,
              config: this.props.config,
              onChange: this.onChange(id),
              onRemove: this.onRemove(id),
              root: (this.props.root + `[${ clause.joiner }][]`),
              group: clause.joiner
            }

            return ( clause.field ? <Clause { ...newProps } /> : <SubQuery {...newProps } /> )
          }) }

          { (this.props.onRemove
            && <Button negative basic icon onClick={ this.props.onRemove }>
                <Icon name='trash alternate outline'/>
                Remove Group
              </Button>) }
        </Grouper>
      </React.Fragment>
    )
  }
}
