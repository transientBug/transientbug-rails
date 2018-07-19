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
  state = { visible: false }

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
    return false
  }

  getHelp = (_e) => {
    console.log("Help dialogue toggled")
    return false
  }

  render = () => (
    <div className="tb navbar search">
      <div className="tb navbar-item">
        <div className="tb header">
          <div className="tb title">Earth Rendering</div>
          <div className="tb query"><small>earth +tag:computers +( created_date:[2014-01-01,2018-06-14] ) -host:wired.com</small></div>
        </div>
        <div className="tb key">
          <KeyboardShortcut keys={ ["/"] } onKey={ this.onShow } />
        </div>
      </div>
      <div className={ `tb dropdown ${ this.state.visible ? "" : "hidden" }` }>
        <div className="tb content">
          Things go here
        </div>
        <div className="tb tips">
          <div className="left">
            <KeyboardShortcut keys={ { [ ["meta+enter"] ]: ["&#8984;", "&crarr;"] } } onKey={ this.onSearch }>Search</KeyboardShortcut>
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
    const props = {}

    ReactDOM.render(<NavbarSearch { ...props } />, appDiv)
  })
}

export default render
