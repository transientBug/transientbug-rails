import { Component } from "react"
import { Button, Icon } from "semantic-ui-react"

import uuidv4 from "uuid/v4"

import { isObject } from "lodash"

import Clause from "./Clause"
import GrouperHeader from "./GrouperHeader"
import Grouper from "./Grouper"

export default class SubQuery extends Component {
  onAddClause = joiner => () => {
    const [[field, fieldData], ..._tail] = Object.entries(this.props.config.fields) // eslint-disable-line
    const operation = fieldData.default_operation

    this.updateData({
      joiner,
      field,
      operation,
      values: [],
    })
  }

  onAddGroup = joiner => () => this.updateData({ joiner })

  onRemove = id => () => this.removeData(id)

  onChange = _id => data => this.updateData(data)

  updateQueryData(func) {
    return Object.assign({}, this.props.query, func(this.props.query))
  }

  /* eslint no-param-reassign:0 */
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
  /* eslint no-param-reassign:1 */

  render() {
    const headers = Object.entries(this.props.config.joiners)
    const clauses = Object.entries(this.props.query).filter(([_k, v]) => isObject(v))

    return (
      <div>
        { (this.props.query.joiner
          && (
          <input
            type="hidden"
            name={ `${ this.props.root }[id]` }
            value={ this.props.query.id }
          />
          )) }

        <Grouper>
          { headers.map(([joiner, joinerData]) => (
            <GrouperHeader
              key={ joiner }
              group={ joiner }
              data={ joinerData }
              addClause={ this.onAddClause(joiner) }
              addGroup={ this.onAddGroup(joiner) }
            />
          )) }

          { clauses.map(([id, clause]) => {
            const newProps = {
              query: clause,
              config: this.props.config,
              onChange: this.onChange(id),
              onRemove: this.onRemove(id),
              root: (`${ this.props.root }[${ clause.joiner }][]`),
              group: clause.joiner,
              key: id,
            }

            return (clause.field ? <Clause { ...newProps } /> : <SubQuery { ...newProps } />)
          }) }

          { (this.props.onRemove
            && (
            <Button negative basic icon onClick={ this.props.onRemove }>
              <Icon name="trash alternate outline" />
              Remove Group
            </Button>
            )) }
        </Grouper>
      </div>
    )
  }
}
