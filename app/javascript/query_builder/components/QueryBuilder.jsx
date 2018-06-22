import { Component } from "react"

import { Query, QueryDebug } from "."

export class QueryBuilder extends Component {
  state = { query: this.props.query }

  onChange = (val) => this.setState({ query: val })

  onSubmit = (event) => event.target.submit()

  render() {
    const props = Object.assign({}, this.props, {
      onSubmit: this.onSubmit,
      onChange: this.onChange,
      query: this.state.query
    })

    return (
      <div>
        <Query { ...props } />
        <QueryDebug query={ this.state.query } config={ this.props.config } />
      </div>
    )
  }
}
