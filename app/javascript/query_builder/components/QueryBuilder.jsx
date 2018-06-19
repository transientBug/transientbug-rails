import { Component } from "react"
import { Button, Form } from "semantic-ui-react"

import uuidv4 from "uuid/v4"

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

    this.state = {
      query: this.props.query
    }

    this.onChange = this.onChange.bind(this)
    this.onSubmit = this.onSubmit.bind(this)
  }

  onChange(val) {
    this.setState({ query: val })
  }

  onSubmit(event) {
    console.log("Search!", this.state.query, this.props.meta.url)
  }

  render() {
    const props = Object.assign({}, this.props, { onChange: this.onChange, query: this.state.query })

    return (
      <div>
        <Form className="qb root" onSubmit={ this.onSubmit }>
          <Query { ...props } />
          <Button type="submit">Search</Button>
        </Form>
        <QueryDebug query={ this.state.query } />
      </div>
    )
  }
}
