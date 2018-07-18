/* eslint react/no-multi-comp:0 */
import * as Mousetrap from "mousetrap"
import { Component } from "react"

const List = ({ data, joiner }) => data.reduce((prev, curr) => [prev, joiner, curr])

const Kbd = props => (
  <kbd className={ (props.dark ? "dark" : "") }>
    { props.children }
  </kbd>
)

class KeyboardShortcut extends Component {
  constructor(props) {
    super(props)

    Mousetrap.bind(this.props.keys, props.onKey)
  }

  componentWillUnmount() {
    Mousetrap.unbind(this.props.keys)
  }

  render = () => (
    <div className="key-combo">
      <List data={ this.props.keys.map(key => (<Kbd dark>{ key }</Kbd>)) } joiner=" + " />
      { this.props.text }
    </div>
  )
}

class NavbarSearch extends Component {
  constructor() {
    super()

    Mousetrap.bind(["?"], () => {
      console.log("Is dropdown visible?", this.state.visible)

      if (!this.state.visible)
        return true

      console.log("Help dialogue toggle")
      return false
    })
  }

  state = { visible: false }

  onShow = (_e) => {
    this.setState({ visible: true })
    return false
  }

  onHide = (_e) => {
    this.setState({ visible: false })
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
            <div className="key-combo">
              <kbd className="dark">&#8984;</kbd>+<kbd className="dark">&crarr;</kbd> Search
            </div>
          </div>
          <div className="right">
            <div className="key-combo">
              <kbd className="dark">?</kbd> Help
            </div>
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
