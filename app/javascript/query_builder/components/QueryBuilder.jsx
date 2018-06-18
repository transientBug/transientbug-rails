import React, { Component } from "react"
import uuidv4 from "uuid/v4"

import { Query } from "."

export class QueryBuilder extends Component {
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
        <Query data={ this.state.query } fields={ this.props.fields } config={ this.props.config } onChange={ this.onChange } />
        <code>
          <pre>
            { JSON.stringify(this.state.query, null, 2) }
          </pre>
        </code>
      </div>
    )
  }
}
