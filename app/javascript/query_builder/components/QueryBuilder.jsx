import { Component } from "react"

import { Query, QueryDebug } from "."

export class QueryBuilder extends Component {
  state = { query: this.props.query }

  onChange = (val) => { this.setState({ query: val }) }

  onSubmit = (event) => {
    //console.log("Search!", this.state.query, this.props.url)
    event.target.submit()

    //App.buildRequest({ url: this.props.url, method: this.props.method, payload: this.state }).then((response) => {
      //response.json().then((body) => {
        //if(response.ok)
          //Turbolinks.visit(body.location)
      //})
    //})
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
