import { Component } from "react"

import { Query } from "."

const QueryDebug = ({ query }) => (
  <code>
    <pre>
      { JSON.stringify(query, null, 2) }
    </pre>
  </code>
)

export class QueryBuilder extends Component {
  constructor(props) {
    super(props)

    this.state = { query: this.props.query }

    this.onChange = this.onChange.bind(this)
    this.onSubmit = this.onSubmit.bind(this)
  }

  onChange(val) { this.setState({ query: val }) }

  onSubmit(event) {
    console.log("Search!", this.state.query, this.props.meta.url)
    event.target.submit()
  }

  render() {
    const props = Object.assign({}, this.props, {
      onSubmit: this.onSubmit,
      onChange: this.onChange,
      query: this.state.query
    })

    return (
      <div>
        <Query { ...props } />
        <QueryDebug query={ this.state.query } />
      </div>
    )
  }
}
