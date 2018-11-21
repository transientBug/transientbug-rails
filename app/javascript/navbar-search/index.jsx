import { Component } from "react"
import moment from "moment"

import { KeyboardShortcut } from "../common"

class NavbarSearch extends Component {
  state = { visible: false, query: this.props.query || "" }

  componentWillMount = () => {
    document.addEventListener("mousedown", this.handleOutsideClick, false)
  }

  componentDidUpdate = () => {
    if (this.state.submit) this.formElement.submit()
  }

  componentWillUnmount = () => {
    document.removeEventListener("mousedown", this.handleOutsideClick, false)
  }

  onShow = (_e) => {
    this.setState({ visible: true })
    this.queryInput.focus()
    return false
  }

  onHide = (_e) => {
    this.setState({ visible: false })
    this.queryInput.blur()
    return false
  }

  getHelp = _e => false

  handleQueryChange = (event) => {
    event.preventDefault()

    this.setState({ query: event.target.value })
  }

  moveCursorToQueryEnd = (event) => {
    const tempValue = event.target.value
    event.target.value = '' // eslint-disable-line
    event.target.value = tempValue // eslint-disable-line
  }

  handleOutsideClick = (event) => {
    if (this.node.contains(event.target)) return
    if (!this.state.visible) return

    this.onHide()
  }

  precannedSearch = (query) => {
    return (event) => {
      event.preventDefault()

      this.setState({ query, submit: true })
    }
  }

  render = () => (
    <div
      className="tb navbar search"
      onClick={ this.onShow }
      onKeyPress={ _e => true }
      ref={ (node) => { this.node = node } }
      role="searchbox"
      tabIndex={ -1 }
    >
      <div className="tb navbar-item">
        <div className="tb input">
          <form action={ this.props.path } method="get" ref={ (form) => { this.formElement = form } }>
            <input
              className="mousetrap"
              ref={ (input) => { this.queryInput = input } }
              value={ this.state.query }
              onChange={ this.handleQueryChange }
              onFocus={ this.moveCursorToQueryEnd }
              type="search"
              name="q"
            />
          </form>
        </div>
        <div className="tb key">
          <KeyboardShortcut keys={ ["/"] } onKey={ this.onShow } />
        </div>
      </div>
      <div className={ `tb dropdown ${ this.state.visible ? "" : "hidden" }` }>
        <div className="tb content">
          <table className="ui collapsing compact small selectable celled table">
            <thead>
              <tr>
                <th>Name</th>
                <th>Query</th>
              </tr>
            </thead>
            <tbody>
              <tr onClick={ this.precannedSearch("NOT has:tags") }>{ /* eslint-disable-line */ }
                <td>Untagged</td>
                <td><pre>NOT has:tags</pre></td>
              </tr>
              <tr onClick={ this.precannedSearch(`after:${ moment().subtract(3, "months").format("YYYY-MM-DD") }`) }>{ /* eslint-disable-line */ }
                <td>In the last month</td>
                <td><pre>{ `after:${ moment().subtract(3, "months").format("YYYY-MM-DD") }` }</pre></td>
              </tr>
              <tr onClick={ this.precannedSearch("sort:created_at") }>{ /* eslint-disable-line */ }
                <td>Sort newest first</td>
                <td><pre>sort:created_at</pre></td>
              </tr>
              <tr onClick={ this.precannedSearch("+sort:created_at") }>{ /* eslint-disable-line */ }
                <td>Sort oldest first</td>
                <td><pre>+sort:created_at</pre></td>
              </tr>
            </tbody>
          </table>
        </div>
        <div className="tb tips">
          <div className="left">
            <KeyboardShortcut keys={ { [ ["enter"] ]: ["&crarr;"] } } onKey={ _e => true }>Search</KeyboardShortcut>
          </div>
          <div className="right">
            <KeyboardShortcut keys={ ["?"] } onKey={ this.getHelp }>Help</KeyboardShortcut>
            <KeyboardShortcut keys={ ["esc"] } onKey={ this.onHide }>Close</KeyboardShortcut>
          </div>
        </div>
      </div>
    </div>
  )
}

const render = (selector) => {
  const appDivs = document.querySelectorAll(selector)

  appDivs.forEach((appDiv) => {
    const props = Object.assign({}, appDiv.dataset)

    ReactDOM.render(<NavbarSearch { ...props } />, appDiv)
  })
}

export default render
