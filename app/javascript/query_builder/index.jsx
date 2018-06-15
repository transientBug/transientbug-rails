import React, { Component } from "react"
import ReactDOM from "react-dom"
import uuidv4 from "uuid/v4"

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

const queryToIdHash = (query) => {
  const joinerKeys = Object.keys(BuilderConfig.joiners)

  return Object.entries(query)
    .filter((i) => joinerKeys.includes(i[0]))
    .flatMap((joinerData, i) => {
      return joinerData[1].flatMap((clause, j) => {
        return Object.assign({ joiner: joinerData[0] }, clause)
      })
    })
    .reduce((memo, val) => { memo[ val.id ] = val; return memo }, {})
}

const idHashToQuery = (hash) => {
  return Object.entries(hash).reduce((memo, [key, val]) => {
    memo[ val.joiner ] = (memo[ val.joiner ] || [])
    memo[ val.joiner ].push(val)
    return memo
  }, {})
}

const TextWidget = ({ value, onChange }) => <input type="text" value={ value } onChange={ onChange } />
const NumberWidget = ({ value, onChange }) => <input type="number" value={ value } onChange={ onChange } />
const DateWidget = ({ value, onChange }) => <input type="date" value={ value } onChange={ onChange } />

const FieldSelect = ({ value, onChange, fields }) => (
  <div className="field">
    <select className="ui dropdown" name={ name } value={ value } onChange={ onChange } disabled={ Object.keys(fields).length <= 1 }>
      { entryMap(fields, ([field, fieldData], i) => (
        <option key={ i } value={ field }>{ fieldData.display_name }</option>
      )) }
    </select>
  </div>
)

class Clause extends Component {
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
    return BuilderConfig.types[ this.fieldData.type ]
  }

  get supportedOperations() {
    const supported_operation_names = this.typeData.supported_operations

    return pick(BuilderConfig.operations, supported_operation_names)
  }

  selectField(event) {
    const field = event.target.value

    if (field === this.props.data.field)
      return

    const type = BuilderConfig.types[ this.props.fields[ field ].type ]
    const operation = type.supported_operations[0]

    this.props.onChange({ id: this.props.data.id, field, operation, values: [] })
  }

  selectOperation(event) {
    const operation = event.target.value

    if (operation === this.props.data.operation)
      return

    const values = this.props.data.values
    values.length = (BuilderConfig.operations[ operation ].composed_of || [0]).length

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
    const length = (BuilderConfig.operations[ this.props.data.operation ].composed_of || [0]).length
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

const RemoveButton = (props) => (
  <button className={ ["ui tiny basic negative button", (props.children ? "" : "icon")].join(" ") } { ...props } >
    <i className="trash icon" />
    { props.children }
  </button>
)

class Query extends Component {
  constructor(props) {
    super(props)

    this.onChange = this.onChange.bind(this)
    this.onAdd = this.onAdd.bind(this)
    this.onAddGroup = this.onAddGroup.bind(this)
    this.onRemove = this.onRemove.bind(this)
  }

  onChange(val) {
    const idHash = queryToIdHash(this.props.data)

    const newData = {}
    newData[ val.id ] = Object.assign({}, idHash[ val.id ], val)

    Object.assign(idHash, newData)

    this.props.onChange(Object.assign({}, this.props.data, idHashToQuery(idHash)))
  }

  onAdd(joiner) {
    return () => {
      const idHash = queryToIdHash(this.props.data)

      const [field, fieldData] = Object.entries(this.props.fields)[0]

      const fieldType = BuilderConfig.types[ fieldData.type ]
      const operation = fieldType.supported_operations[0]

      const id = uuidv4()
      const newData = {}
      newData[ id ] = {
        id,
        joiner,
        field,
        operation,
        values: []
      }

      Object.assign(idHash, newData)

      this.props.onChange(Object.assign({}, this.props.data, idHashToQuery(idHash)))
    }
  }

  onAddGroup(joiner) {
    return () => {
      const idHash = queryToIdHash(this.props.data)

      const id = uuidv4()
      const newData = {}
      newData[ id ] = {
        id,
        joiner,
        must: [],
        should: [],
        must_not: []
      }

      Object.assign(idHash, newData)

      this.props.onChange(Object.assign({}, this.props.data, idHashToQuery(idHash)))
    }
  }

  onRemove(id) {
    return () => {
      const idHash = queryToIdHash(this.props.data)

      delete idHash[ id ]

      this.props.onChange(Object.assign({}, this.props.data, idHashToQuery(idHash)))
    }
  }

  render() {
    let removeButton
    if (this.props.onRemove)
      removeButton = (
        <RemoveButton onClick={ this.props.onRemove }>Remove Group</RemoveButton>
      )

    return (
      <div className="qb query ui list">
        { Object.entries(BuilderConfig.joiners).map(([joiner, joinerData]) => {
          const joinerClauses = this.props.data[ joiner ]
          if (!joinerClauses)
            return (
              <div className="qb group item" key={ joiner }>
                <i className="filter icon" />
                <div className="content">
                  <div className="header">
                    { joinerData.display_name }
                  </div>
                  <button className="ui tiny button" onClick={ this.onAdd(joiner) }>
                    <i className="plus icon" />
                    Add { joinerData.display_name } Clause
                  </button>
                  <button className="ui tiny button" onClick={ this.onAddGroup(joiner) }>
                    <i className="plus icon" />
                    Add Group
                  </button>
                </div>
              </div>
             )

          return (
            <div className="qb group item" key={ joiner }>
              <i className="filter icon" />
              <div className="content">
                <div className="header">
                  { joinerData.display_name }
                </div>
                { joinerClauses.map((clause) => {
                  const newProps = {
                    data: clause,
                    fields: this.props.fields,
                    onChange: this.onChange,
                    onRemove: this.onRemove(clause.id),
                    key: clause.id
                  }

                  return ( clause.field
                    ? <Clause { ...newProps } />
                    : <Query { ...newProps } />
                  )
                }) }
                <button className="ui tiny button" onClick={ this.onAdd(joiner) }>
                  <i className="plus icon" />
                  Add { joinerData.display_name } Clause
                </button>
                <button className="ui tiny button" onClick={ this.onAddGroup(joiner) }>
                  <i className="plus icon" />
                  Add Group
                </button>
              </div>
            </div>
          )
        }).filter((i) => i) }

        { removeButton }
      </div>
    )
  }
}

class QueryBuilder extends Component {
  constructor(props) {
    super(props)

    this.state = {
      query: {
        id: 0,
        should: [
          { id: 1, field: "title", operation: "match", values: ["earth"] },
          { id: 2, field: "description", operation: "match", values: ["earth"] }
        ],
        must: [
          { id: 3, field: "tags", operation: "equal", values: ["computers"] },
          {
            id: 4,
            must: [
              { id: 5, field: "created_at", operation: "[between]", values: ["2014-01-01", "2018-06-14"] },
            ]
          }
        ],
        must_not: [
          { id: 6, field: "host", operation: "equal", values: ["wired.com"] }
        ]
      }
    }

    this.onChange = this.onChange.bind(this)
  }

  onChange(val) {
    this.setState({ query: val })
  }

  render() {
    return (
      <div className="qb root ui form">
        <Query data={ this.state.query } fields={ this.props.fields } onChange={ this.onChange } />
        <code>
          <pre>
            { JSON.stringify(this.state.query, null, 2) }
          </pre>
        </code>
      </div>
    )
  }
}

export const renderQueryBuilder = (selector) => {
  const appDiv = document.querySelector(selector)
  const fields = JSON.parse(appDiv.innerText)

  ReactDOM.render(<QueryBuilder fields={ fields } />, appDiv)
}
