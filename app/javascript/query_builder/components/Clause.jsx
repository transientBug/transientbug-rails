import { Component } from "react"
import { Form, Button } from "semantic-ui-react"

import { pick } from "../utils"

export class Clause extends Component {
  constructor(props) {
    super(props)

    this.selectField = this.selectField.bind(this)
    this.selectOperation = this.selectOperation.bind(this)
    this.changeValue = this.changeValue.bind(this)
  }

  get fieldData() {
    return this.props.fields[ this.props.query.field ]
  }

  get typeData() {
    return this.props.config.types[ this.fieldData.type ]
  }

  get widget() {
    return this.props.widgetMap[ this.fieldData.type ]
  }

  get supportedOperations() {
    const supported_operation_names = this.typeData.supported_operations

    return pick(this.props.config.operations, supported_operation_names)
  }

  selectField(event, { value }) {
    const field = value

    if (field === this.props.query.field)
      return

    const type = this.props.config.types[ this.props.fields[ field ].type ]
    const operation = type.supported_operations[0]

    this.props.onChange({ id: this.props.query.id, field, operation, values: [] })
  }

  selectOperation(event, { value }) {
    const operation = value

    if (operation === this.props.query.operation)
      return

    const values = this.props.query.values
    values.length = (this.props.config.operations[ operation ].composed_of || [0]).length

    this.props.onChange({ id: this.props.query.id, operation, values: values })
  }

  changeValue(i) {
    return (event) => {
      const values = this.props.query.values
      values[i] = event.target.value

      this.props.onChange({ id: this.props.query.id, values: values })
    }
  }

  render() {
    const length = (this.props.config.operations[ this.props.query.operation ].composed_of || [0]).length
    const values = Array(length).fill().map((_, i, values) => this.props.query.values[ i ] || "")

    const fieldOptions = Object.entries(this.props.fields).reduce((memo, [field, fieldData]) => {
      memo.push({ key: field, value: field, text: fieldData.display_name })
      return memo
    }, [])

    const operationOptions = Object.entries(this.supportedOperations).reduce((memo, [op, opData]) => {
      memo.push({ key: op, value: op, text: opData.display_name })
      return memo
    }, [])

    return (
      <Form.Group className="qb clause">
        <Button icon='trash' basic negative onClick={ this.props.onRemove }/>

        <Form.Select name="field" options={ fieldOptions } onChange={ this.selectField } value={ this.props.query.field } />
        <Form.Select name="operation" options={ operationOptions } onChange={ this.selectOperation } value={ this.props.query.operation } />

        { values.map((val, i) => (
          <Form.Field key={ i }>
            { this.widget({ value: val, onChange: this.changeValue(i) }) }
          </Form.Field>
        )) }
      </Form.Group>
    )
  }
}
