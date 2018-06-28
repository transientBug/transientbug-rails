import { Component } from "react"
import { Form, Button } from "semantic-ui-react"

export default class Clause extends Component {
  static toOptions(config) {
    return Object.entries(config)
      .reduce((memo, [field, fieldData]) => {
        memo.push({ key: field, value: field, text: fieldData.display_name })
        return memo
      }, [])
  }

  get queryValues() {
    return this.props.query.values || []
  }

  get currentValues() {
    let values = []

    const { parameters } = this.props.config.operations[ this.props.query.operation ]

    if (parameters > 0)
      values = Array(parameters).fill().map((_, i) => this.queryValues[ i ] || "")

    return values
  }

  selectField = (_event, { value }) => {
    const fieldData = this.props.config.fields[ value ]
    const operation = fieldData.default_operation

    this.props.onChange({
      id: this.props.query.id,
      field: value,
      operation,
      values: []
    })
  }

  selectOperation = (_event, { value }) => {
    const values = this.queryValues
    values.length = this.props.config.operations[ value ].parameters

    this.props.onChange({ id: this.props.query.id, operation: value, values })
  }

  changeValue = i => (_event, { value }) => {
    const values = this.queryValues
    values[ i ] = value

    this.props.onChange({ id: this.props.query.id, values })
  }

  render() {
    const currentFieldData = this.props.config.fields[ this.props.query.field ]

    const fieldOptions = Clause.toOptions(this.props.config.fields)
    const operationOptions = Clause.toOptions(currentFieldData.operations)

    return (
      <Form.Group className="qb clause">
        <Button icon="trash" basic negative onClick={ this.props.onRemove } />

        <input type="hidden" name={ `${ this.props.root }[id]` } value={ this.props.query.id } />

        <Form.Select
          options={ fieldOptions }
          onChange={ this.selectField }
          value={ this.props.query.field }
        />

        <input type="hidden" name={ `${ this.props.root }[field]` } value={ this.props.query.field } />

        <Form.Select
          options={ operationOptions }
          onChange={ this.selectOperation }
          value={ this.props.query.operation }
        />

        <input type="hidden" name={ `${ this.props.root }[operation]` } value={ this.props.query.operation } />

        { this.currentValues.map((value, i) => (
          /* eslint react/no-array-index-key:0 */
          <Form.Field key={ i }>
            { currentFieldData.widget({
              name: `${ this.props.root }[values][]`,
              value,
              onChange: this.changeValue(i)
            }) }
          </Form.Field>
        )) }
      </Form.Group>
    )
  }
}
