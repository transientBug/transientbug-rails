import React, { Component } from "react"

import { pick } from "../utils"

import { RemoveButton, FieldSelect } from "."

export class Clause extends Component {
  constructor(props) {
    super(props)

    this.selectField = this.selectField.bind(this)
    this.selectOperation = this.selectOperation.bind(this)
    this.changeValue = this.changeValue.bind(this)
  }

  get fieldData() {
    return this.props.fields[ this.props.data.field ]
  }

  get typeData() {
    return this.props.config.types[ this.fieldData.type ]
  }

  get supportedOperations() {
    const supported_operation_names = this.typeData.supported_operations

    return pick(this.props.config.operations, supported_operation_names)
  }

  selectField(event) {
    const field = event.target.value

    if (field === this.props.data.field)
      return

    const type = this.props.config.types[ this.props.fields[ field ].type ]
    const operation = type.supported_operations[0]

    this.props.onChange({ id: this.props.data.id, field, operation, values: [] })
  }

  selectOperation(event) {
    const operation = event.target.value

    if (operation === this.props.data.operation)
      return

    const values = this.props.data.values
    values.length = (this.props.config.operations[ operation ].composed_of || [0]).length

    this.props.onChange({ id: this.props.data.id, operation, values: values })
  }

  changeValue(i) {
    return (event) => {
      const values = this.props.data.values
      values[i] = event.target.value

      this.props.onChange({ id: this.props.data.id, values: values })
    }
  }

  render() {
    const length = (this.props.config.operations[ this.props.data.operation ].composed_of || [0]).length
    const values = Array(length).fill().map((_, i, values) => this.props.data.values[ i ] || "")

    return (
      <div className="qb clause inline fields">
        <RemoveButton onClick={ this.props.onRemove } />

        <FieldSelect name="field" fields={ this.props.fields } value={ this.props.data.field } onChange={ this.selectField } />
        <FieldSelect name="operation" fields={ this.supportedOperations } value={ this.props.data.operation } onChange={ this.selectOperation } />

        { values.map((val, i) => (
          <div className="field" key={ i }>
            { this.typeData.widget({ value: val, onChange: this.changeValue(i) }) }
          </div>
        )) }
      </div>
    )
  }
}
