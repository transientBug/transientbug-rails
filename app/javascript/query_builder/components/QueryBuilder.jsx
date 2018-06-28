import { Component } from "react"

import Query from "./Query"
import QueryDebug from "./QueryDebug"

import { queryToIdHash } from "../utils"

export default class QueryBuilder extends Component {
  state = { query: queryToIdHash(this.props.config, this.props.query) }

  onChange = val => this.setState({ query: val })

  onSubmit = event => event.target.submit()

  render() {
    const props = Object.assign({}, this.props, {
      onSubmit: this.onSubmit,
      onChange: this.onChange,
      query: this.state.query,
    })

    return (
      <div>
        <Query { ...props } />
        <QueryDebug query={ this.state.query } />
      </div>
    )
  }
}
