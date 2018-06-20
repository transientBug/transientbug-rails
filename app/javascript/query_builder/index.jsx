import { QueryBuilder } from "./components"
import { TextWidget, NumberWidget, DateWidget } from "./widgets"

const WidgetMap = {
  text: (props) => <TextWidget {...props} />,
  keyword: (props) => <TextWidget {...props} />,
  number: (props) => <NumberWidget {...props} />,
  date: (props) => <DateWidget {...props} />
}

export const renderQueryBuilder = (selector) => {
  const appDiv = document.querySelector(selector)

  const parsedConfig = {
    fields: JSON.parse(appDiv.dataset.fields),
    config: JSON.parse(appDiv.dataset.config),
    query: JSON.parse(appDiv.dataset.query),
    widgetMap: WidgetMap
  }

  const props = Object.assign({}, appDiv.dataset, parsedConfig)

  console.dir(props)

  ReactDOM.render(<QueryBuilder { ...props } />, appDiv, () => {
    appDiv.classList.remove("hidden")
  })
}
