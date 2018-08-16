/* eslint react/no-multi-comp:0 */
import * as Mousetrap from "mousetrap"
import { Component } from "react"

import { isArray } from "lodash"

const Kbd = props => (
  <kbd className={ (props.dark ? "dark" : "") } dangerouslySetInnerHTML={ { __html: props.children } } />
)

class KeyboardShortcut extends Component {
  constructor(props) {
    super(props)

    if (isArray(this.props.keys)) {
      this.keys = this.props.keys
      this.displayKeys = this.props.keys
    } else {
      this.keys = Object.keys(this.props.keys)[0] // eslint-disable-line
      this.displayKeys = this.props.keys[ this.keys ]
    }

    Mousetrap.bind(this.keys, props.onKey)
  }

  componentWillUnmount() {
    Mousetrap.unbind(this.keys)
  }

  render = () => (
    <div className="key-combo">
      { this.displayKeys.map(key => (
        <Kbd key={ key } dark>{ key }</Kbd>
      )).reduce((prev, curr) => [prev, " + ", curr]) }
      { this.props.children }
    </div>
  )
}

class NavbarSearch extends Component {
  state = { visible: false, query: this.props.query, title: this.props.title }

  onShow = (_e) => {
    this.setState({ visible: true })
    return false
  }

  onHide = (_e) => {
    this.setState({ visible: false })
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

  render = () => (
    <div className="tb navbar search" onClick={ this.onShow }>
      <div className="tb navbar-item">
        {(this.state.visible ? (
          <div className="tb input">
            <form action={ this.props.path } method="get">
              <input
                className="mousetrap"
                ref={ (input) => { this.queryInput = input } }
                autoFocus
                onFocus={ this.moveCursorToQueryEnd }
                value={ this.state.query }
                onChange={ this.handleQueryChange }
                type="search"
                name="q"
              />
            </form>
          </div>
        ) : (
          <div className="tb header">
            <div className="tb title">{ this.state.title }</div>
            <div className="tb query"><small>{ this.state.query }</small></div>
          </div>
        ))}
        <div className="tb key">
          <KeyboardShortcut keys={ ["/"] } onKey={ this.onShow } />
        </div>
      </div>
      <div className={ `tb dropdown ${ this.state.visible ? "" : "hidden" }` }>
        <div className="tb content">
          Recent searches go here
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
