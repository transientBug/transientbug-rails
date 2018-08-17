import { Component } from "react"

import { KeyboardShortcut } from "../common"

class NavbarSearch extends Component {
  state = { visible: false, query: this.props.query }

  componentWillMount = () => {
    document.addEventListener("mousedown", this.handleOutsideClick, false)
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

  onSearch = (_e) => {
    console.log("Search!")
    return true
  }

  getHelp = (_e) => {
    console.log("Help dialogue toggled")
    return false
  }

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

  render = () => (
    <div className="tb navbar search" onClick={ this.onShow } ref={ (node) => { this.node = node } }>
      <div className="tb navbar-item">
        <div className="tb input">
          <form action={ this.props.path } method="get">
            <input
              className="mousetrap"
              ref={ (input) => { this.queryInput = input } }
              onFocus={ this.moveCursorToQueryEnd }
              value={ this.state.query }
              onChange={ this.handleQueryChange }
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
          Recent searches and saved searches coming soon!
        </div>
        <div className="tb tips">
          <div className="left">
            <KeyboardShortcut keys={ { [ ["enter"] ]: ["&crarr;"] } } onKey={ this.onSearch }>Search</KeyboardShortcut>
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
