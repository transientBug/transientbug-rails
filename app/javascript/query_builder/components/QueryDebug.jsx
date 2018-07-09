import { Component } from "react"
import { Accordion, Icon } from "semantic-ui-react"

export default class QueryDebug extends Component {
  state = { activeIndex: -1 }

  handleClick = (_event, titleProps) => {
    const { index } = titleProps
    const { activeIndex } = this.state

    const newIndex = activeIndex === index ? -1 : index

    this.setState({ activeIndex: newIndex })
  }

  render() {
    const { activeIndex } = this.state

    return (
      <Accordion>
        <Accordion.Title active={ activeIndex === 0 } index={ 0 } onClick={ this.handleClick }>
          <Icon name="dropdown" />
          Query Debug
        </Accordion.Title>
        <Accordion.Content active={ activeIndex === 0 }>
          <code>
            <pre>
              { JSON.stringify(this.props.query, null, 2) }
            </pre>
          </code>
        </Accordion.Content>
      </Accordion>
    )
  }
}
