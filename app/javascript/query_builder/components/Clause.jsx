import { Component } from "react"
import { Form, Button } from "semantic-ui-react"

import { pick } from "../utils"
import { isNil } from "lodash"

export class Clause extends Component {
  constructor(props) {
    super(props)

    this.selectField = this.selectField.bind(this)
    this.selectOperation = this.selectOperation.bind(this)
    this.changeValue = this.changeValue.bind(this)
  }

  get queryValues() {
    return this.props.query.values || []
  }

  typeData(field) {
    return this.props.config.types[ field.type ]
  }

  supportedOperationNames(fieldData) {
    const supported_operations = this.typeData(fieldData).supported_operations

    const exclude = fieldData.exclude_operations
    if (isNil(exclude))
      return supported_operations

    return supported_operations.filter((i) => !exclude.includes(i))
  }

  supportedOperations(fieldData) {
    return pick(this.props.config.operations, this.supportedOperationNames(fieldData))
  }

  parameterCount(operation) {
    let length = this.props.config.operations[ operation ].parameters
    if(isNil(length))
      length = 1

    return length
  }

  selectField(event, { value }) {
    const field = value

    if (field === this.props.query.field)
      return

    const fieldData = this.props.fields[ field ]

    let operation = this.typeData(fieldData).default_operation
    if(isNil(operation))
      operation = this.supportedOperationNames(fieldData)[0]

    const values = []

    this.props.onChange({ id: this.props.query.id, field, operation, values })
  }

  selectOperation(event, { value }) {
    const operation = value

    if (operation === this.props.query.operation)
      return

    const values = this.queryValues
    values.length = this.parameterCount(operation)

    this.props.onChange({ id: this.props.query.id, operation, values })
  }

  changeValue(i) {
    return (event) => {
      const values = this.queryValues
      values[i] = event.target.value

      this.props.onChange({ id: this.props.query.id, values })
    }
  }

  get currentValues() {
    let values = []
    let length = this.parameterCount(this.props.query.operation)

    if (length > 0)
      values = Array(length).fill().map((_, i, values) => this.queryValues[ i ] || "")

    return values
  }

  render() {
    const fieldData = this.props.fields[ this.props.query.field ]
    const fieldOptions = Object.entries(this.props.fields)
      .reduce((memo, [field, fieldData]) => {
        memo.push({ key: field, value: field, text: fieldData.display_name })
        return memo
      }, [])

    const operationOptions = Object.entries(this.supportedOperations(fieldData))
      .reduce((memo, [op, opData]) => {
        memo.push({ key: op, value: op, text: opData.display_name })
        return memo
      }, [])

    const widget = this.props.widgetMap[ fieldData.type ]

    return (
      <Form.Group className="qb clause">
        <Button icon='trash' basic negative onClick={ this.props.onRemove }/>

        <Form.Select name="field" options={ fieldOptions } onChange={ this.selectField } value={ this.props.query.field } />
        <Form.Select name="operation" options={ operationOptions } onChange={ this.selectOperation } value={ this.props.query.operation } />

        { this.currentValues.map((val, i) => (
          <Form.Field key={ i }>
            { widget({ value: val, onChange: this.changeValue(i) }) }
          </Form.Field>
        )) }
      </Form.Group>
    )
  }
}
