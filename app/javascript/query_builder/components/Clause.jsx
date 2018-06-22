import { Component } from "react"
import { Form, Button } from "semantic-ui-react"

import { pick } from "../utils"
import { isNil } from "lodash"

export class Clause extends Component {
  get queryValues() {
    return this.props.query.values || []
  }

  get currentValues() {
    let values = []
    let length = this.parameterCount(this.props.query.operation)

    if (length > 0)
      values = Array(length).fill().map((_, i, values) => this.queryValues[ i ] || "")

    return values
  }

  parameterCount(operation) {
    let length = this.props.config.operations[ operation ].parameters
    if(isNil(length))
      length = 1

    return length
  }

  selectField = (event, { value }) => {
    const fieldData = this.props.config.fields[ value ]
    const operation = fieldData.default_operation

    this.props.onChange({
      id: this.props.query.id,
      field: value,
      operation,
      values: []
    })
  }

  selectOperation = (event, { value }) => {
    const values = this.queryValues
    values.length = this.parameterCount(value)

    this.props.onChange({ id: this.props.query.id, operation: value, values })
  }

  changeValue = (i) => {
    return (event, { value }) => {
      const values = this.queryValues
      values[i] = value

      this.props.onChange({ id: this.props.query.id, values })
    }
  }

  toOptions(config) {
    return Object.entries(config)
      .reduce((memo, [field, fieldData]) => {
        memo.push({ key: field, value: field, text: fieldData.display_name })
        return memo
      }, [])
  }

  render() {
    const currentFieldData = this.props.config.fields[ this.props.query.field ]

    const fieldOptions = this.toOptions(this.props.config.fields)
    const operationOptions = this.toOptions(currentFieldData.operations)

    return (
      <Form.Group className="qb clause">
        <Button icon='trash' basic negative onClick={ this.props.onRemove }/>

        <input type="hidden" name={ `${ this.props.root }[id]` } value={ this.props.query.id } />

        <Form.Select options={ fieldOptions } onChange={ this.selectField } value={ this.props.query.field } />
        <input type="hidden" name={ `${ this.props.root }[field]` } value={ this.props.query.field } />

        <Form.Select options={ operationOptions } onChange={ this.selectOperation } value={ this.props.query.operation } />
        <input type="hidden" name={ `${ this.props.root }[operation]` } value={ this.props.query.operation } />

        { this.currentValues.map((val, i) => (
          <Form.Field key={ i }>
            { currentFieldData.widget({ name: `${ this.props.root }[values][]`,  value: val, onChange: this.changeValue(i) }) }
          </Form.Field>
        )) }
      </Form.Group>
    )
  }
}
