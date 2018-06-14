import React from "react"
import ReactDOM from "react-dom"

const pick = (obj, props) => props.reduce((a, e) => (a[e] = obj[e], a), {})

const TextWidget = ({ value, onChange }) => <input type="text" value={ value } onChange={ onChange } />
const NumberWidget = ({ value, onChange }) => <input type="number" value={ value } onChange={ onChange } />
const DateWidget = ({ value, onChange }) => <input type="date" value={ value } onChange={ onChange } />

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
      "widget": TextWidget
    },
    "keyword": {
      "supported_operations": [ "equal" ],
      "widget": TextWidget
    },
    "number": {
      "supported_operations": [ "[between]", "[between)", "(between]", "(between)", "less_than", "less_than_or_equal", "equal", "greater_than_or_equal", "greater_than" ],
      "widget": NumberWidget
      },
    "date": {
      "supported_operations": [ "[between]", "[between)", "(between]", "(between)", "less_than", "less_than_or_equal", "equal", "greater_than_or_equal", "greater_than" ],
      "widget": DateWidget
    },
  },
  "joiners": {
    "should": { "display_name": "Should", "description": "" },
    "must": { "display_name": "Must", "description": "" },
    "must_not": { "display_name": "Must Not", "description": "" }
  }
}

class Operation extends React.Component {
  constructor(props) {
    super(props)

    this.state = props.clause
    this.clause = props.clause
    this.operation = props.operation
    this.type = props.type

    this.i = props.i || 0
  }

  get opData() {
    return BuilderConfig.operations[ this.operation ]
  }

  get typeData() {
    return BuilderConfig.types[ this.type ]
  }

  render() {
    if (this.opData.composed_of) {
      return (
        <div>
          <Operation operation={ this.opData.composed_of[0] } type={ this.type } i={ 0 } clause={ this.clause } />
          { this.opData.display_name }
          <Operation operation={ this.opData.composed_of[1] } type={ this.type } i={ 1 } clause={ this.clause } />
        </div>
      )
    }

    const TagName = this.typeData.widget
    console.log(this.state, this.type, this.operation)

    return (
      <div>
        <TagName value={ this.state.values[ this.i ] } />
      </div>
    )
  }
}

class Clause extends React.Component {
  constructor(props) {
    super(props)

    this.state = props.clause
    this.clause = props.clause
    this.fields = props.fields

    this.selectField = this.selectField.bind(this)
    this.selectOperation = this.selectOperation.bind(this)
  }

  selectField(event) {
    const field = event.target.value

    if (field == this.state.field)
      return

    const type = BuilderConfig.types[ this.fields[ field ].type ]
    const operation = type.supported_operations[0]

    this.setState({ field, operation })
  }

  selectOperation(event) {
    const operation = event.target.value

    if (operation == this.state.operation)
      return

    this.setState({ operation })
  }

  get supportedOperations() {
    const field_type = this.fields[ this.state.field ].type
    const supported_operation_names = BuilderConfig.types[ field_type ].supported_operations

    return pick(BuilderConfig.operations, supported_operation_names)
  }

  render() {
    return (
      <div>
        <select name="field" value={ this.state.field } onChange={ this.selectField }>
          { Object.entries(this.fields).map(([field, fieldData], i) => {
            return ( <option key={ i } value={ field }>{ fieldData.display_name }</option> )
          }) }
        </select>

        <select name="operation" value={ this.state.operation } onChange={ this.selectOperation }>
          { Object.entries(this.supportedOperations).map(([operation, opData], i) => {
            return ( <option key={ i } value={ operation }>{ opData.display_name }</option> )
          }) }
        </select>

        <Operation operation={ this.state.operation } type={ this.fields[ this.state.field ].type } clause={ this.clause } />
      </div>
    )
  }
}

const GroupOrClause = ({ fields, data }) => {
  if(data.field)
    return ( <Clause clause={ data } fields={ fields } /> )

  return ( <Group group={ data } fields={ fields } /> )
}

class Group extends React.Component {
  constructor(props) {
    super(props)

    this.group = props.group
    this.fields = props.fields
  }

  render() {
    return (
      <div className="qb group">
        { Object.entries(BuilderConfig.joiners).map(([joiner, joinerData], i) => {
          return (
            <div key={ i }>
              <h2>{ joinerData.display_name }</h2>
              { (this.group[ joiner ] || []).map((group_or_clause, i) => {
                return ( <GroupOrClause key={ i } group_or_clause data={ group_or_clause } fields={ this.fields } /> )
              }) }
            </div>
          )
        }) }
      </div>
    )
  }
}

class QueryBuilder extends React.Component {
  constructor(props) {
    super(props)

    this.fields = props.fields

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
      <div>
        <Group group={ this.state.rootJoiner } fields={ this.fields } />
      </div>
    )
  }
}

export const renderQueryBuilder = (selector) => {
  const appDiv = document.querySelector(selector)
  const fields = JSON.parse(appDiv.innerText)

  ReactDOM.render(<QueryBuilder fields={ fields } />, appDiv)
}
