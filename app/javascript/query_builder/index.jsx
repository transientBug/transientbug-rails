import React, { Component } from "react"
import ReactDOM from "react-dom"

const BuilderConfig = {
  "operations": {
    "[between]": { "display_name": "After til Before", "description": "", "composed_of": ["greater_than", "less_than"] },
    "[between)": { "display_name": "After til Before or On", "description": "", "composed_of": ["greater_than", "less_than_or_equal"] },
    "(between]": { "display_name": "On or After til Before", "description": "", "composed_of": ["greater_than_or_equal", "less_than"] },
    "(between)": { "display_name": "On or After til Before or On", "description": "", "composed_of": ["greater_than_or_equal", "less_than_or_equal"] },
    "less_than": { "display_name": "Less Than", "description": "" },
    "less_than_or_equal": { "display_name": "Less Than or Equal", "description": "" },
    "equal": { "display_name": "Equals", "description": "" },
    "greater_than_or_equal": { "display_name": "Greater Than or Equal", "description": "" },
    "greater_than": { "display_name": "Greater Than", "description": "" },
    "match": { "display_name": "Matches", "description": "" }
  },
  "types": {
    "text": {
      "supported_operations": [ "match" ],
      "widget": (props) => <TextWidget {...props} />
    },
    "keyword": {
      "supported_operations": [ "equal" ],
      "widget": (props) => <TextWidget {...props} />
    },
    "number": {
      "supported_operations": [ "[between]", "[between)", "(between]", "(between)", "less_than", "less_than_or_equal", "equal", "greater_than_or_equal", "greater_than" ],
      "widget": (props) => <NumberWidget {...props} />
    },
    "date": {
      "supported_operations": [ "[between]", "[between)", "(between]", "(between)", "less_than", "less_than_or_equal", "equal", "greater_than_or_equal", "greater_than" ],
      "widget": (props) => <DateWidget {...props} />
    },
  },
  "joiners": {
    "should": { "display_name": "Should", "description": "" },
    "must": { "display_name": "Must", "description": "" },
    "must_not": { "display_name": "Must Not", "description": "" }
  }
}

const pick = (obj, props) => props.reduce((a, e) => (a[e] = obj[e], a), {})
const entryMap = (obj, mapFunc) => Object.entries(obj).map(mapFunc)

const TextWidget = ({ value, onChange }) => <input type="text" value={ value } onChange={ onChange } />
const NumberWidget = ({ value, onChange }) => <input type="number" value={ value } onChange={ onChange } />
const DateWidget = ({ value, onChange }) => <input type="date" value={ value } onChange={ onChange } />

class Operation extends Component {
  get opData() {
    return BuilderConfig.operations[ this.props.operation ]
  }

  get typeData() {
    return BuilderConfig.types[ this.props.type ]
  }

  render() {
    if (this.opData.composed_of) {
      return (
        <div className="qb composed operator">
          <Operation operation={ this.opData.composed_of[0] } type={ this.props.type } i={ 0 } clause={ this.props.clause } />
          { this.opData.display_name }
          <Operation operation={ this.opData.composed_of[1] } type={ this.props.type } i={ 1 } clause={ this.props.clause } />
        </div>
      )
    }

    const widgetFactory = this.typeData.widget

    return (
      <div className="qb operator">
        { widgetFactory({ value: this.props.clause.values[ this.props.i || 0 ] }) }
      </div>
    )
  }
}

const FieldSelect = ({ value, onChange, fields }) => (
  <select name={ name } value={ value } onChange={ onChange }>
    { entryMap(fields, ([field, fieldData], i) => (
      <option key={ i } value={ field }>{ fieldData.display_name }</option>
    )) }
  </select>
)

const QueryOrClause = ({ fields, data }) => {
  if(data.field)
    return ( <Clause data={ data } fields={ fields } /> )

  return ( <Query data={ data } fields={ fields } /> )
}

class Clause extends Component {
  constructor(props) {
    super(props)

    this.selectField = this.selectField.bind(this)
    this.selectOperation = this.selectOperation.bind(this)
  }

  selectField(event) {
    const field = event.target.value

    if (field == this.props.field)
      return

    const type = BuilderConfig.types[ this.fieldData.type ]
    const operation = type.supported_operations[0]

    console.log("Set state", { field, operation })
    //this.setState({ field, operation })
  }

  selectOperation(event) {
    const operation = event.target.value

    if (operation == this.props.operation)
      return

    console.log("Set state", { operation })
    //this.setState({ operation })
  }

  get fieldData() {
    return this.props.fields[ this.props.clause.field ]
  }

  get supportedOperations() {
    const supported_operation_names = BuilderConfig.types[ this.fieldData.type ].supported_operations

    return pick(BuilderConfig.operations, supported_operation_names)
  }

  render() {
    return (
      <div className="qb clause">
        <FieldSelect name="field" fields={ this.props.fields } value={ this.props.clause.field } onChange={ this.selectField } />
        <FieldSelect name="operation" fields={ this.supportedOperations } value={ this.props.clause.operation } onChange={ this.selectOperation } />

        <Operation operation={ this.props.clause.operation } type={ this.fieldData.type } clause={ this.props.clause } />
      </div>
    )
  }
}

class Query extends Component {
  constructor(props) {
    super(props)

    this.state = Object.entries(props.data)
      .flatMap((joinerData, i) => joinerData[1].flatMap((clause, j) => {
        return Object.assign({ id: `${i}${j}`, joiner: joinerData[0] }, clause)
      }))
      .reduce((memo, val) => { memo[ val.id ] = val; return memo }, {})

    this.onChange = this.onChange.bind(this)
  }

  onChange(val) {
    console.log(val)
  }

  render() {
    return (
      <div className="qb query">
        { entryMap(this.state, ([id, group_or_clause]) => (
          <QueryOrClause key={ id } data={ group_or_clause } fields={ this.props.fields } onChange={ this.onChange } />
        )) }
      </div>
    )
  }
}

class QueryBuilder extends Component {
  constructor(props) {
    super(props)

    this.state = {
      rootJoiner: {
        should: [
          { field: "title", operation: "match", values: ["earth"] },
          { field: "description", operation: "match", values: ["earth"] }
        ],
        must: [
          { field: "tags", operation: "equal", values: ["computers"] },
          {
            must: [
              { field: "created_at", operation: "[between]", values: ["2014-01-01", "2018-06-14"] },
            ]
          }
        ],
        must_not: [
          { field: "host", operation: "equal", values: ["wired.com"] }
        ]
      }
    }
  }

  render() {
    return (
      <div className="qb root">
        <Query data={ this.state.rootJoiner } fields={ this.props.fields } />
      </div>
    )
  }
}

export const renderQueryBuilder = (selector) => {
  const appDiv = document.querySelector(selector)
  const fields = JSON.parse(appDiv.innerText)

  ReactDOM.render(<QueryBuilder fields={ fields } />, appDiv)
}
